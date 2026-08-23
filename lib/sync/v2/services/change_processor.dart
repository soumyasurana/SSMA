import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import 'package:ssma/models/product.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/models/godown_item.dart';
import 'package:ssma/models/godown_movement.dart';
import 'package:ssma/services/db_service.dart';

import '../models/sync_change_log.dart';
import 'conflict_resolver.dart';
import 'change_journal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Result type
// ─────────────────────────────────────────────────────────────────────────────

/// Statistics returned after processing a batch of incoming changes.
class ChangeProcessorResult {
  final int applied;
  final int skipped; // duplicates (same changeId already stored)
  final int conflicts; // resolved conflicts (applied or rejected)
  final int errors; // unknown entity types or unexpected exceptions
  final int lastProcessedSeq; // last attempted change sequence in the batch

  const ChangeProcessorResult({
    required this.applied,
    required this.skipped,
    required this.conflicts,
    required this.errors,
    required this.lastProcessedSeq,
  });

  @override
  String toString() =>
      'ChangeProcessorResult(applied=$applied, skipped=$skipped, conflicts=$conflicts, errors=$errors, lastProcessedSeq=$lastProcessedSeq)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Entity handler abstraction
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract handler for a specific entity type.
///
/// Implement one subclass per entity and register it with [EntityRegistry].
/// The sync engine is completely decoupled from entity-specific logic —
/// it never contains `if entityType == 'Product'` blocks.
///
/// To add a new syncable entity:
///   1. Implement [EntitySyncHandler] for the entity.
///   2. Add one line to [EntityRegistry.registerAll].
///   That's all — no changes to the engine.
abstract class EntitySyncHandler {
  /// Entity type string matching [SyncChangeLog.entityType].
  /// Examples: 'Product', 'Sale', 'Customer'.
  String get entityType;

  /// Applies an incoming change to the local Isar database.
  ///
  /// [operation] is 'CREATE', 'UPDATE', or 'DELETE'.
  /// [payload] is the deserialized JSON snapshot of the entity.
  ///
  /// MUST be called from within an active [isar.writeTxn] block.
  /// Returns true if applied, false if rejected (conflict).
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Entity registry
// ─────────────────────────────────────────────────────────────────────────────

/// Central registry that maps entity type strings → sync handlers.
///
/// The [ChangeProcessor] looks up the handler by entity type and delegates
/// all apply logic. Adding a new entity type never requires touching the engine.
class EntityRegistry {
  static final Map<String, EntitySyncHandler> _handlers = {};

  /// Registers a handler, overwriting any existing handler for the same type.
  static void register(EntitySyncHandler handler) {
    _handlers[handler.entityType] = handler;
    debugPrint(
        '[EntityRegistry]: registered handler for "${handler.entityType}"');
  }

  /// Returns the handler for [entityType], or null if not registered.
  static EntitySyncHandler? get(String entityType) => _handlers[entityType];

  /// All registered entity type names (for diagnostics).
  static Iterable<String> get registeredTypes => _handlers.keys;

  /// Registers all entity handlers used by this application.
  ///
  /// Called once at app startup from [SyncInitializerV2.initialize].
  /// To add a new syncable entity: add exactly one line here.
  static void registerAll({required Isar isar}) {
    register(ProductSyncHandler());
    register(CustomerSyncHandler());
    register(SupplierSyncHandler());
    register(SaleSyncHandler());
    register(PurchaseSyncHandler());
    register(CustomerPaymentSyncHandler());
    register(SupplierPaymentSyncHandler());
    register(GodownItemSyncHandler());
    register(GodownMovementSyncHandler());
    // 📌 New entity: register(YourEntitySyncHandler());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Change processor
// ─────────────────────────────────────────────────────────────────────────────

/// Processes batches of incoming [SyncChangeLog] entries from peers.
///
/// Each entry is applied via [EntityRegistry] inside its own write transaction.
/// Failures in one entry do not block the rest of the batch.
class ChangeProcessor {
  final Isar isar;
  final ChangeJournal journal;
  final ConflictResolver conflictResolver;

  ChangeProcessor({
    required this.isar,
    required this.journal,
    required this.conflictResolver,
  });

  /// Processes a batch of incoming changes and returns aggregate statistics.
  Future<ChangeProcessorResult> processBatch(
      List<SyncChangeLog> changes) async {
    int applied = 0, skipped = 0, conflicts = 0, errors = 0;
    int lastProcessedSeq = -1;

    for (final change in changes) {
      try {
        final result = await _processSingle(change);
        if (result == _ApplyResult.unknownType) {
          errors++;
          debugPrint(
              '[ChangeProcessor]: ⚠ no handler for entityType="${change.entityType}"');
          // The receive cursor is a contiguous watermark.  Moving it beyond
          // an entry we cannot understand would permanently drop that entry.
          break;
        } else {
          switch (result) {
            case _ApplyResult.applied:
              applied++;
              break;
            case _ApplyResult.duplicate:
              skipped++;
              break;
            case _ApplyResult.conflict:
              conflicts++;
              break;
            case _ApplyResult.unknownType:
              break;
          }
          // Applied, duplicate and conflict entries have all been durably
          // handled, so it is safe to include them in the contiguous cursor.
          lastProcessedSeq = change.changeSeq;
        }
      } catch (e, st) {
        errors++;
        debugPrint(
            '[ChangeProcessor]: ❌ error on changeId=${change.changeId}: $e\n$st');
        // Do not process later rows: a cursor may only acknowledge a
        // contiguous prefix of the remote journal.
        break;
      }
    }

    debugPrint('[ChangeProcessor]: batch done — '
        'applied=$applied skipped=$skipped conflicts=$conflicts errors=$errors');
    return ChangeProcessorResult(
      applied: applied,
      skipped: skipped,
      conflicts: conflicts,
      errors: errors,
      lastProcessedSeq: lastProcessedSeq,
    );
  }

  Future<_ApplyResult> _processSingle(SyncChangeLog change) async {
    _ApplyResult result = _ApplyResult.applied;

    final handler = EntityRegistry.get(change.entityType);
    if (handler == null) {
      return _ApplyResult.unknownType;
    }

    final payload = jsonDecode(change.payload) as Map<String, dynamic>;

    await isar.writeTxn(() async {
      // Keep duplicate detection and local sequence allocation in the same
      // transaction as the entity/journal writes. Otherwise concurrent pushes
      // can assign the same local changeSeq and break cursor pagination.
      final existing = await isar.syncChangeLogs
          .filter()
          .changeIdEqualTo(change.changeId)
          .findFirst();
      if (existing != null) {
        result = _ApplyResult.duplicate;
        return;
      }

      final storedJournalEntry = journal.buildRemoteEntry(change,
          localSeq: await journal.getNextSeq());

      // Apply the entity change via the handler
      final applyOutcome = await handler.applyChange(
          payload, change.operation, conflictResolver, isar);
      if (applyOutcome == false) {
        result = _ApplyResult.conflict;
      }

      // Record the remote change in the local journal (for future peer pulls)
      await journal.putRemoteEntry(storedJournalEntry);
    });

    if (result == _ApplyResult.applied &&
        (change.entityType == 'Customer' ||
            change.entityType == 'Sale' ||
            change.entityType == 'CustomerPayment')) {
      await DBService.reconcileAllCustomerAccounts();
    }

    return result;
  }
}

enum _ApplyResult { applied, duplicate, conflict, unknownType }

// ─────────────────────────────────────────────────────────────────────────────
// Concrete entity handlers — one class per entity
// ─────────────────────────────────────────────────────────────────────────────

// ── Product ─────────────────────────────────────────────────────────────────

class ProductSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'Product';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = Product.fromJson(payload);
    final existing =
        await isar.products.filter().uuidEqualTo(incoming.uuid).findFirst();

    if (existing == null) {
      incoming.isSynced = true;
      await isar.products.put(incoming);
      return true;
    }

    if (operation == 'DELETE') {
      existing
        ..deleted = true
        ..updatedAt = incoming.updatedAt
        ..version = incoming.version
        ..isSynced = true;
      await isar.products.put(existing);
      return true;
    }

    if (existing.deleted && !incoming.deleted) {
      return false;
    }

    if (conflictResolver.shouldApplyIncoming(_makeCtx(
        entityType,
        incoming.uuid,
        incoming.version,
        existing.version,
        incoming.updatedAt.millisecondsSinceEpoch,
        existing.updatedAt.millisecondsSinceEpoch,
        incoming.deviceId,
        existing.deviceId))) {
      incoming
        ..isarId = existing.isarId
        ..isSynced = true;
      await isar.products.put(incoming);
      return true;
    }
    return false;
  }
}

class CustomerSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'Customer';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = Customer.fromJson(payload);
    final existing =
        await isar.customers.filter().uuidEqualTo(incoming.uuid).findFirst();

    if (existing == null) {
      // Brand new customer — apply as-is. The local reconciliation pass after
      // sync will correct pendingDues/advanceBalance if needed.
      incoming.isSynced = true;
      await isar.customers.put(incoming);
      return true;
    }

    if (operation == 'DELETE') {
      existing
        ..deleted = true
        ..updatedAt = incoming.updatedAt
        ..version = incoming.version
        ..isSynced = true;
      await isar.customers.put(existing);
      return true;
    }

    if (existing.deleted && !incoming.deleted) {
      return false;
    }

    if (conflictResolver.shouldApplyIncoming(_makeCtx(
        entityType,
        incoming.uuid,
        incoming.version,
        existing.version,
        incoming.updatedAt.millisecondsSinceEpoch,
        existing.updatedAt.millisecondsSinceEpoch,
        incoming.deviceId,
        existing.deviceId))) {
      // IMPORTANT: pendingDues and advanceBalance are *derived* fields that
      // are always computed from actual Sale and CustomerPayment records.
      // Never overwrite locally-computed balances with remote values — the
      // remote may have a different (stale) view of these cached totals.
      // The post-sync reconciliation pass will correct them from transactions.
      incoming
        ..isarId = existing.isarId
        ..isSynced = true
        ..pendingDues = existing.pendingDues
        ..advanceBalance = existing.advanceBalance;
      await isar.customers.put(incoming);
      return true;
    }
    return false;
  }
}

// ── Supplier ─────────────────────────────────────────────────────────────────

class SupplierSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'Supplier';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = Supplier.fromJson(payload);
    final existing =
        await isar.suppliers.filter().uuidEqualTo(incoming.uuid).findFirst();

    if (existing == null) {
      incoming.isSynced = true;
      await isar.suppliers.put(incoming);
      return true;
    }

    if (operation == 'DELETE') {
      existing
        ..deleted = true
        ..updatedAt = incoming.updatedAt
        ..version = incoming.version
        ..isSynced = true;
      await isar.suppliers.put(existing);
      return true;
    }

    if (conflictResolver.shouldApplyIncoming(_makeCtx(
        entityType,
        incoming.uuid,
        incoming.version,
        existing.version,
        incoming.updatedAt.millisecondsSinceEpoch,
        existing.updatedAt.millisecondsSinceEpoch,
        incoming.deviceId,
        existing.deviceId))) {
      incoming
        ..isarId = existing.isarId
        ..isSynced = true;
      await isar.suppliers.put(incoming);
      return true;
    }
    return false;
  }
}

// ── Sale ─────────────────────────────────────────────────────────────────────

class SaleSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'Sale';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = Sale.fromJson(payload);
    final existing =
        await isar.sales.filter().uuidEqualTo(incoming.uuid).findFirst();

    if (existing == null) {
      incoming.isSynced = true;
      await isar.sales.put(incoming);
      return true;
    }

    if (operation == 'DELETE') {
      existing
        ..deleted = true
        ..updatedAt = incoming.updatedAt
        ..version = incoming.version
        ..isSynced = true;
      await isar.sales.put(existing);
      return true;
    }

    if (conflictResolver.shouldApplyIncoming(_makeCtx(
        entityType,
        incoming.uuid,
        incoming.version,
        existing.version,
        incoming.updatedAt.millisecondsSinceEpoch,
        existing.updatedAt.millisecondsSinceEpoch,
        incoming.deviceId,
        existing.deviceId))) {
      incoming
        ..isarId = existing.isarId
        ..isSynced = true;
      await isar.sales.put(incoming);
      return true;
    }
    return false;
  }
}

// ── Purchase ─────────────────────────────────────────────────────────────────

class PurchaseSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'Purchase';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = Purchase.fromJson(payload);
    final existing =
        await isar.purchases.filter().uuidEqualTo(incoming.uuid).findFirst();

    if (existing == null) {
      incoming.isSynced = true;
      await isar.purchases.put(incoming);
      return true;
    }

    if (operation == 'DELETE') {
      existing
        ..deleted = true
        ..updatedAt = incoming.updatedAt
        ..version = incoming.version
        ..isSynced = true;
      await isar.purchases.put(existing);
      return true;
    }

    if (conflictResolver.shouldApplyIncoming(_makeCtx(
        entityType,
        incoming.uuid,
        incoming.version,
        existing.version,
        incoming.updatedAt.millisecondsSinceEpoch,
        existing.updatedAt.millisecondsSinceEpoch,
        incoming.deviceId,
        existing.deviceId))) {
      incoming
        ..isarId = existing.isarId
        ..isSynced = true;
      await isar.purchases.put(incoming);
      return true;
    }
    return false;
  }
}

// ── CustomerPayment ──────────────────────────────────────────────────────────

class CustomerPaymentSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'CustomerPayment';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = CustomerPayment.fromJson(payload);
    final existing = await isar.customerPayments
        .filter()
        .uuidEqualTo(incoming.uuid)
        .findFirst();

    if (existing == null) {
      incoming.isSynced = true;
      await isar.customerPayments.put(incoming);
      return true;
    }

    if (operation == 'DELETE') {
      existing
        ..deleted = true
        ..updatedAt = incoming.updatedAt
        ..version = incoming.version
        ..isSynced = true;
      await isar.customerPayments.put(existing);
      return true;
    }

    if (conflictResolver.shouldApplyIncoming(_makeCtx(
        entityType,
        incoming.uuid,
        incoming.version,
        existing.version,
        incoming.updatedAt.millisecondsSinceEpoch,
        existing.updatedAt.millisecondsSinceEpoch,
        incoming.deviceId,
        existing.deviceId))) {
      incoming
        ..isarId = existing.isarId
        ..isSynced = true;
      await isar.customerPayments.put(incoming);
      return true;
    }
    return false;
  }
}

// ── SupplierPayment ──────────────────────────────────────────────────────────

class SupplierPaymentSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'SupplierPayment';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = SupplierPayment.fromJson(payload);
    final existing = await isar.supplierPayments
        .filter()
        .uuidEqualTo(incoming.uuid)
        .findFirst();

    if (existing == null) {
      incoming.isSynced = true;
      await isar.supplierPayments.put(incoming);
      return true;
    }

    if (operation == 'DELETE') {
      existing
        ..deleted = true
        ..updatedAt = incoming.updatedAt
        ..version = incoming.version
        ..isSynced = true;
      await isar.supplierPayments.put(existing);
      return true;
    }

    if (conflictResolver.shouldApplyIncoming(_makeCtx(
        entityType,
        incoming.uuid,
        incoming.version,
        existing.version,
        incoming.updatedAt.millisecondsSinceEpoch,
        existing.updatedAt.millisecondsSinceEpoch,
        incoming.deviceId,
        existing.deviceId))) {
      incoming
        ..isarId = existing.isarId
        ..isSynced = true;
      await isar.supplierPayments.put(incoming);
      return true;
    }
    return false;
  }
}

// ── GodownItem ───────────────────────────────────────────────────────────────

class GodownItemSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'GodownItem';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = GodownItem.fromJson(payload);
    final existing =
        await isar.godownItems.filter().uuidEqualTo(incoming.uuid).findFirst();

    if (existing == null) {
      incoming.isSynced = true;
      await isar.godownItems.put(incoming);
      return true;
    }

    if (operation == 'DELETE') {
      existing
        ..deleted = true
        ..updatedAt = incoming.updatedAt
        ..version = incoming.version
        ..isSynced = true;
      await isar.godownItems.put(existing);
      return true;
    }

    if (conflictResolver.shouldApplyIncoming(_makeCtx(
        entityType,
        incoming.uuid,
        incoming.version,
        existing.version,
        incoming.updatedAt.millisecondsSinceEpoch,
        existing.updatedAt.millisecondsSinceEpoch,
        incoming.deviceId,
        existing.deviceId))) {
      incoming
        ..isarId = existing.isarId
        ..isSynced = true;
      await isar.godownItems.put(incoming);
      return true;
    }
    return false;
  }
}

// ── GodownMovement ───────────────────────────────────────────────────────────

class GodownMovementSyncHandler implements EntitySyncHandler {
  @override
  String get entityType => 'GodownMovement';

  @override
  Future<bool> applyChange(
    Map<String, dynamic> payload,
    String operation,
    ConflictResolver conflictResolver,
    Isar isar,
  ) async {
    final incoming = GodownMovement.fromJson(payload);
    final existing = await isar.godownMovements
        .filter()
        .uuidEqualTo(incoming.uuid)
        .findFirst();

    if (existing == null) {
      await isar.godownMovements.put(incoming);
      return true;
    }

    // Godown movements are immutable audit records; if already exists, skip
    return true;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper
// ─────────────────────────────────────────────────────────────────────────────

ConflictContext _makeCtx(
  String entityType,
  String entityId,
  int incomingVer,
  int existingVer,
  int incomingMs,
  int existingMs,
  String incomingDevice,
  String existingDevice,
) {
  return ConflictContext(
    entityType: entityType,
    entityId: entityId,
    incomingVersion: incomingVer,
    existingVersion: existingVer,
    incomingUpdatedAtMs: incomingMs,
    existingUpdatedAtMs: existingMs,
    incomingDeviceId: incomingDevice,
    existingDeviceId: existingDevice,
  );
}
