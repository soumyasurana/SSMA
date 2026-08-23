import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:ssma/models/customer.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/change_log.dart';
import 'package:ssma/models/item.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/sale_item.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/models/peer_state.dart';
import 'package:ssma/models/godown_item.dart';
import 'package:ssma/models/godown_movement.dart';

// ── Sync v2 models ──────────────────────────────────────────────────────────
import 'package:ssma/sync/v2/models/sync_change_log.dart';
import 'package:ssma/sync/v2/models/peer_device.dart';
import 'package:ssma/sync/v2/models/sync_cursor.dart';
import 'package:ssma/sync/v2/models/pairing_request.dart';
import 'package:ssma/sync/v2/services/change_journal.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;

class DBService {
  static Isar? _isarInstance;
  static const _uuid = Uuid();

  // ─────────────────────────────────────────────────────────────────────────
  // Pending journal entry — carries v2 SyncChangeLog parameters that must be
  // written in a SEPARATE Isar write transaction AFTER the entity write txn
  // commits. Isar 3.x does not allow reads inside a write transaction, so
  // merging both into one txn causes the journal write to fail silently.
  // ─────────────────────────────────────────────────────────────────────────
  static const _kUnknownDevice = 'unknown';

  // Holds v2 journal params to be flushed after the entity txn commits.
  // Each DBService write method accumulates entries here while in its writeTxn,
  // then calls _flushJournalEntries() immediately after the txn completes.
  static final List<_JournalEntry> _pendingJournalEntries = [];

  /// Writes the legacy v1 ChangeLog entry inside the CURRENT write transaction
  /// and enqueues a v2 journal entry to be flushed afterwards via
  /// [_flushJournalEntries]. Must be called from within an active writeTxn.
  ///
  /// Returns a [_JournalEntry] describing the v2 write, or null if the entity
  /// UUID cannot be resolved.
  static Future<_JournalEntry?> _appendChangeLog({
    required String collection,
    required String operationType,
    required Map<String, dynamic> payload,
    int recordId = 0,
    String? entityUuid,
    int entityVersion = 1,
  }) async {
    final deviceId = syncV2?.deviceId ?? _kUnknownDevice;

    // Auto-extract entity UUID from the payload if not explicitly supplied.
    // All entity toJson() methods emit the UUID as the 'id' field.
    final resolvedUuid = entityUuid ?? payload['id'] as String?;

    // Map legacy 'upsert' operationType to v2 canonical operations.
    String v2Operation;
    if (operationType == 'DELETE') {
      v2Operation = 'DELETE';
    } else if (operationType == 'CREATE') {
      v2Operation = 'CREATE';
    } else if (operationType == 'UPDATE') {
      v2Operation = 'UPDATE';
    } else {
      // Legacy 'upsert': default to UPDATE (safe — higher version wins).
      v2Operation = 'UPDATE';
    }

    // ── Legacy v1 ChangeLog (written inside the CURRENT writeTxn) ───────────
    // NOTE: We intentionally do NOT read sortByChangeSeqDesc inside a write
    // transaction (Isar 3.x does not support reads in write txns). Instead
    // we generate a rough sequence as a timestamp-based tiebreaker; the v1
    // ChangeLog is only used for backward compat and ordering is best-effort.
    final log = ChangeLog()
      ..opId = _uuid.v4()
      ..changeSeq = DateTime.now().millisecondsSinceEpoch // monotonic approx
      ..collection = collection
      ..recordId = recordId
      ..operationType = operationType
      ..payload = jsonEncode(payload)
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..synced = false
      ..originDeviceId = deviceId;
    await isar.changeLogs.put(log);

    // ── v2 SyncChangeLog — queued immediately so local mutations are not
    // lost if the sync engine is not ready yet. They are flushed once
    // SyncInitializerV2 initializes and registers the shared singleton.
    if (resolvedUuid != null) {
      final entry = _JournalEntry(
        entityType: collection,
        entityId: resolvedUuid,
        operation: v2Operation,
        entityVersion: entityVersion,
        payload: payload,
      );
      _pendingJournalEntries.add(entry);
      return entry;
    }
    return null;
  }

  /// Writes all enqueued v2 [_JournalEntry] records to [SyncChangeLog] in
  /// their OWN Isar write transaction, separate from the entity write.
  ///
  /// Call this immediately after every entity writeTxn completes. If sync is
  /// not available yet, the entries remain queued and are flushed later by
  /// [flushPendingJournalEntries].
  static Future<void> _flushJournalEntries() async {
    await flushPendingJournalEntries();
  }

  static bool _isFlushingJournal = false;

  /// Flushes any buffered v2 journal entries once the sync engine is ready.
  ///
  /// This is safe to call repeatedly. Successfully flushed entries are removed
  /// from the pending queue; failed attempts remain buffered for a later retry.
  static Future<void> flushPendingJournalEntries() async {
    if (_pendingJournalEntries.isEmpty) return;
    if (syncV2 == null) return;
    if (_isFlushingJournal) return;
    _isFlushingJournal = true;

    try {
      while (_pendingJournalEntries.isNotEmpty) {
        final entry = _pendingJournalEntries.first;
        try {
          await syncV2!.changeJournal.append(
            entityType: entry.entityType,
            entityId: entry.entityId,
            operation: entry.operation,
            entityVersion: entry.entityVersion,
            payload: entry.payload,
          );
          _pendingJournalEntries.removeAt(0);
        } catch (e) {
          debugPrint('[DBService]: ❌ Failed to flush journal entry for '
              '${entry.entityType}/${entry.entityId}: $e');
          _pendingJournalEntries.removeAt(0);
          _pendingJournalEntries.add(entry);
          break;
        }
      }
    } finally {
      _isFlushingJournal = false;
    }
  }

  static Future<void> _putProductSafe(Product product) async {
    final uuidValue = product.uuid.trim();
    if (uuidValue.isEmpty) {
      product.uuid = _uuid.v4();
    }

    if (product.deviceId.trim().isEmpty || product.deviceId == 'unknown') {
      product.deviceId = syncV2?.deviceId ?? 'unknown';
    }

    if (product.isarId != Isar.autoIncrement) {
      await isar.products.put(product);
    } else {
      await isar.products.putByUuid(product);
    }
  }

  static void _ensureCustomerSyncFields(Customer customer) {
    if (customer.uuid.trim().isEmpty) {
      customer.uuid = _uuid.v4();
    }
    if (customer.deviceId.trim().isEmpty || customer.deviceId == 'unknown') {
      customer.deviceId = syncV2?.deviceId ?? 'unknown';
    }
  }

  static Future<void> initializeIsar() async {
    if (_isarInstance != null && _isarInstance!.isOpen) {
      return;
    }

    // Fail startup if multiple Isar instances are detected before we open ours.
    if (Isar.instanceNames.isNotEmpty) {
      final names = Isar.instanceNames;
      debugPrint(
          'Isar Architecture Audit [ERROR]: Multiple Isar instances detected: $names');
      throw StateError(
          'Isar Architecture Audit Failed: Multiple Isar instances detected: $names');
    }

    final dir = await getApplicationDocumentsDirectory();
    _isarInstance = await Isar.open(
      [
        // ── Legacy business models (v1) ──────────────────────────
        CustomerSchema,
        ProductSchema,
        ItemSchema,
        ChangeLogSchema,
        SaleSchema,
        PurchaseSchema,
        CustomerPaymentSchema,
        SupplierSchema,
        SupplierPaymentSchema,
        PeerStateSchema,
        GodownItemSchema,
        GodownMovementSchema,
        // ── Sync v2 models ──────────────────────────────────────
        SyncChangeLogSchema,
        PeerDeviceSchema,
        SyncCursorSchema,
        PairingRequestSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
    );

    // Fail startup if multiple Isar instances are detected after open
    if (Isar.instanceNames.length > 1) {
      final names = Isar.instanceNames;
      debugPrint(
          'Isar Architecture Audit [ERROR]: Multiple Isar instances detected after open: $names');
      throw StateError(
          'Isar Architecture Audit Failed: Multiple Isar instances detected after open: $names');
    }

    debugPrint(
        'Isar Architecture Audit: Shared Isar instance initialized (hashCode=${_isarInstance.hashCode}, name=${_isarInstance?.name}, openInstances=${Isar.instanceNames})');

    // Run duplicate/stale peer cleanup migration
    await cleanupDuplicateAndStalePeers();

    // Reconcile customer credit/advance balances
    await reconcileAllCustomerAccounts();
  }

  /// Backfills the v2 journal with CREATE entries for any legacy entity rows
  /// that predate the new sync engine.
  ///
  /// This is intentionally idempotent: if a row already has a CREATE entry
  /// for its UUID, it is skipped.
  static Future<void> backfillSyncV2Journal(ChangeJournal journal) async {
    debugPrint('DBService [V2 BACKFILL]: Starting journal backfill...');

    await _backfillTable<Product>(
      entityType: 'Product',
      journal: journal,
      fetchRows: () => isar.products.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => row.version,
      payload: (row) => row.toJson(),
    );

    await _backfillTable<Customer>(
      entityType: 'Customer',
      journal: journal,
      fetchRows: () => isar.customers.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => row.version,
      payload: (row) => row.toJson(),
    );

    await _backfillTable<Supplier>(
      entityType: 'Supplier',
      journal: journal,
      fetchRows: () => isar.suppliers.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => row.version,
      payload: (row) => row.toJson(),
    );

    await _backfillTable<Sale>(
      entityType: 'Sale',
      journal: journal,
      fetchRows: () => isar.sales.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => row.version,
      payload: (row) => row.toJson(),
    );

    await _backfillTable<Purchase>(
      entityType: 'Purchase',
      journal: journal,
      fetchRows: () => isar.purchases.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => row.version,
      payload: (row) => row.toJson(),
    );

    await _backfillTable<CustomerPayment>(
      entityType: 'CustomerPayment',
      journal: journal,
      fetchRows: () => isar.customerPayments.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => row.version,
      payload: (row) => row.toJson(),
    );

    await _backfillTable<SupplierPayment>(
      entityType: 'SupplierPayment',
      journal: journal,
      fetchRows: () => isar.supplierPayments.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => row.version,
      payload: (row) => row.toJson(),
    );

    await _backfillTable<GodownItem>(
      entityType: 'GodownItem',
      journal: journal,
      fetchRows: () => isar.godownItems.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => row.version,
      payload: (row) => row.toJson(),
    );

    await _backfillTable<GodownMovement>(
      entityType: 'GodownMovement',
      journal: journal,
      fetchRows: () => isar.godownMovements.where().findAll(),
      entityId: (row) => row.uuid,
      entityVersion: (row) => 1,
      payload: (row) => row.toJson(),
    );

    debugPrint('DBService [V2 BACKFILL]: Journal backfill complete');
  }

  static Isar get isar {
    if (_isarInstance == null || !_isarInstance!.isOpen) {
      throw Exception('Isar database has not been initialized.');
    }
    return _isarInstance!;
  }

  static Future<Isar> getIsarInitialized() async {
    await initializeIsar();
    return isar;
  }

  static Future<List<Product>> getProducts() async {
    return isar.products.filter().deletedEqualTo(false).findAll();
  }

  static Future<void> addProduct(Product product) async {
    final now = DateTime.now();
    product.createdAt = now;
    product.updatedAt = now;
    product.deleted = false;
    product.version = 1;
    product.isSynced = false;
    if (product.deviceId.trim().isEmpty || product.deviceId == 'unknown') {
      product.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    await isar.writeTxn(() async {
      await _putProductSafe(product);
      await _appendChangeLog(
        collection: 'Product',
        operationType: 'CREATE',
        payload: product.toJson(),
        recordId: product.isarId,
        entityUuid: product.uuid,
        entityVersion: product.version,
      );
    });
    await _flushJournalEntries();
    debugPrint(
        '[SYNC_OP]: v2 CREATE journal entry for product uuid=${product.uuid}');
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updateProduct(Product product) async {
    product.updatedAt = DateTime.now();
    product.isSynced = false;
    product.version += 1;
    if (product.deviceId.trim().isEmpty || product.deviceId == 'unknown') {
      product.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    await isar.writeTxn(() async {
      await _putProductSafe(product);
      await _appendChangeLog(
        collection: 'Product',
        operationType: 'UPDATE',
        payload: product.toJson(),
        recordId: product.isarId,
        entityUuid: product.uuid,
        entityVersion: product.version,
      );
    });
    await _flushJournalEntries();
    debugPrint(
        '[SYNC_OP]: v2 UPDATE journal entry for product uuid=${product.uuid}, version=${product.version}');
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteProduct(String productUuid) async {
    final product =
        await isar.products.filter().uuidEqualTo(productUuid).findFirst();
    if (product == null) {
      return;
    }
    if (product.deleted) {
      return;
    }

    await isar.writeTxn(() async {
      product.deleted = true;
      product.updatedAt = DateTime.now();
      product.isSynced = false;
      product.version += 1;
      await _putProductSafe(product);
      await _appendChangeLog(
        collection: 'Product',
        operationType: 'DELETE',
        payload: product.toJson(),
        recordId: product.isarId,
        entityUuid: product.uuid,
        entityVersion: product.version,
      );
    });
    await _flushJournalEntries();
    debugPrint(
        '[SYNC_OP]: v2 DELETE (soft) journal entry for product uuid=$productUuid');
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteProductByIsarId(int id) async {
    final product = await isar.products.get(id);
    if (product == null || product.deleted) return;
    await deleteProduct(product.uuid);
  }

  static Future<Product?> getProductById(int id) async {
    return isar.products.get(id);
  }

  static Future<Product?> getProductByUuid(String uuid) async {
    return isar.products
        .filter()
        .uuidEqualTo(uuid)
        .and()
        .deletedEqualTo(false)
        .findFirst();
  }

  static Future<List<Customer>> getCustomers() async {
    final customers =
        await isar.customers.filter().deletedEqualTo(false).findAll();
    final refreshedCustomers = <Customer>[];
    for (final customer in customers) {
      refreshedCustomers.add(
        await recalculateCustomerAccount(customer.uuid) ?? customer,
      );
    }
    return refreshedCustomers;
  }

  static void _enforceCustomerMonetaryInvariants(Customer customer) {
    if (!customer.pendingDues.isFinite ||
        customer.pendingDues.isNaN ||
        customer.pendingDues < 0) {
      customer.pendingDues = 0.0;
    }
    if (!customer.advanceBalance.isFinite ||
        customer.advanceBalance.isNaN ||
        customer.advanceBalance < 0) {
      customer.advanceBalance = 0.0;
    }
  }

  static Future<void> addCustomer(Customer customer) async {
    final now = DateTime.now();
    customer.createdAt = now;
    customer.updatedAt = now;
    customer.deleted = false;
    customer.version = 1;
    customer.isSynced = false;
    _ensureCustomerSyncFields(customer);
    customer.pendingDues = 0.0;
    customer.advanceBalance = 0.0;

    await isar.writeTxn(() async {
      await isar.customers.put(customer);
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'CREATE',
        payload: customer.toJson(),
        recordId: customer.isarId,
        entityUuid: customer.uuid,
        entityVersion: customer.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;
    customer.version += 1;
    _ensureCustomerSyncFields(customer);
    _enforceCustomerMonetaryInvariants(customer);

    await isar.writeTxn(() async {
      await isar.customers.put(customer);
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'UPDATE',
        payload: customer.toJson(),
        recordId: customer.isarId,
        entityUuid: customer.uuid,
        entityVersion: customer.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteCustomer(String customerUuid, {int? isarId}) async {
    Customer? customer;
    if (customerUuid.trim().isNotEmpty) {
      customer =
          await isar.customers.filter().uuidEqualTo(customerUuid).findFirst();
    }
    if (customer == null && isarId != null) {
      customer = await isar.customers.get(isarId);
    }
    if (customer == null) {
      return;
    }

    // Safety check: repair any non-finite (NaN, Infinity) or negative accounting state from transaction history
    final isPendingValid = customer.pendingDues.isFinite &&
        !customer.pendingDues.isNaN &&
        customer.pendingDues >= 0;
    final isAdvanceValid = customer.advanceBalance.isFinite &&
        !customer.advanceBalance.isNaN &&
        customer.advanceBalance >= 0;

    if (!isPendingValid || !isAdvanceValid) {
      final state = await _computeCustomerAccountState(customer.uuid,
          existingCustomer: customer);
      if (state != null) {
        customer.pendingDues = state.newPendingDues;
        customer.advanceBalance = state.newAdvanceBalance;
      } else {
        customer.pendingDues = 0.0;
        customer.advanceBalance = 0.0;
      }
    }

    _enforceCustomerMonetaryInvariants(customer);

    await isar.writeTxn(() async {
      customer!.deleted = true;
      customer.updatedAt = DateTime.now();
      customer.isSynced = false;
      customer.version += 1;
      await isar.customers.put(customer);
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'DELETE',
        payload: customer.toJson(),
        recordId: customer.isarId,
        entityUuid: customer.uuid,
        entityVersion: customer.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<Customer?> getCustomerById(int id) async {
    return isar.customers.get(id);
  }

  /// Computes the exact customer account state (pendingDues & advanceBalance)
  /// derived from active credit sales and active customer payments.
  static Future<_CustomerAccountState?> _computeCustomerAccountState(
      String customerUuid,
      {Customer? existingCustomer}) async {
    final customer = existingCustomer ??
        await isar.customers.filter().uuidEqualTo(customerUuid).findFirst();
    if (customer == null) return null;

    final sales = await isar.sales
        .filter()
        .customerUuidEqualTo(customerUuid)
        .and()
        .saleTypeEqualTo(SaleType.credit)
        .and()
        .deletedEqualTo(false)
        .findAll();

    final payments = await isar.customerPayments
        .filter()
        .customerUuidEqualTo(customerUuid)
        .and()
        .deletedEqualTo(false)
        .findAll();

    final events = <_CustomerAccountEvent>[
      for (final sale in sales) _CustomerAccountEvent.sale(sale),
      for (final payment in payments) _CustomerAccountEvent.payment(payment),
    ]..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.isarId.compareTo(b.isarId);
      });

    double netPosition = 0.0;
    double availableSalePaymentCredits = 0.0;
    for (final event in events) {
      if (event.sale != null) {
        final sale = event.sale!;
        final totalAmount = _sanitizeAccountAmount(sale.totalAmount);
        final amountReceived = _sanitizeAccountAmount(sale.amountReceived);
        netPosition += totalAmount - amountReceived;
        availableSalePaymentCredits += amountReceived;
        continue;
      }

      final payment = event.payment!;
      final amountReceived = _sanitizeAccountAmount(payment.amountReceived);
      final previousDue = _sanitizeAccountAmount(payment.previousDue);

      // Legacy sale-payment flows sometimes wrote an account-level receipt
      // into both CustomerPayment and an older Sale.amountReceived. When that
      // happened, the payment row still captured the true due before receipt.
      // If the chronological sale ledger says less was due than the payment
      // row says, reverse only the duplicated sale credit before applying the
      // account-level payment.
      final visibleDueBeforePayment = netPosition > 0 ? netPosition : 0.0;
      final duplicatedSaleCredit = previousDue - visibleDueBeforePayment;
      if (duplicatedSaleCredit > 0.01) {
        final repairAmount = [
          duplicatedSaleCredit,
          amountReceived,
          availableSalePaymentCredits,
        ].reduce((a, b) => a < b ? a : b);
        netPosition += repairAmount;
        availableSalePaymentCredits -= repairAmount;
      }

      netPosition -= amountReceived;
    }

    if (!netPosition.isFinite || netPosition.isNaN) {
      netPosition = 0.0;
    } else {
      netPosition = (netPosition * 100).roundToDouble() / 100;
    }

    double newPendingDues = 0.0;
    double newAdvanceBalance = 0.0;

    if (netPosition > 0) {
      newPendingDues = netPosition;
      newAdvanceBalance = 0.0;
    } else if (netPosition < 0) {
      newPendingDues = 0.0;
      newAdvanceBalance = netPosition.abs();
    } else {
      newPendingDues = 0.0;
      newAdvanceBalance = 0.0;
    }

    // Strict non-finite defenses
    if (!newPendingDues.isFinite ||
        newPendingDues.isNaN ||
        newPendingDues < 0) {
      newPendingDues = 0.0;
    }
    if (!newAdvanceBalance.isFinite ||
        newAdvanceBalance.isNaN ||
        newAdvanceBalance < 0) {
      newAdvanceBalance = 0.0;
    }

    return _CustomerAccountState(
      customer: customer,
      newPendingDues: newPendingDues,
      newAdvanceBalance: newAdvanceBalance,
    );
  }

  static double _sanitizeAccountAmount(double value) {
    if (!value.isFinite || value.isNaN || value < 0) return 0.0;
    return value;
  }

  /// Recalculates and persists a customer's account balance.
  static Future<Customer?> recalculateCustomerAccount(
      String customerUuid) async {
    final state = await _computeCustomerAccountState(customerUuid);
    if (state == null) return null;

    final c = state.customer;
    final needsRepair = !c.pendingDues.isFinite ||
        c.pendingDues.isNaN ||
        !c.advanceBalance.isFinite ||
        c.advanceBalance.isNaN ||
        c.pendingDues < 0 ||
        c.advanceBalance < 0;

    if (c.pendingDues != state.newPendingDues ||
        c.advanceBalance != state.newAdvanceBalance ||
        needsRepair) {
      c.pendingDues = state.newPendingDues;
      c.advanceBalance = state.newAdvanceBalance;
      _enforceCustomerMonetaryInvariants(c);
      c.updatedAt = DateTime.now();
      c.isSynced = false;
      c.version += 1;

      await isar.writeTxn(() async {
        await isar.customers.put(c);
        await _appendChangeLog(
          collection: 'Customer',
          operationType: 'UPDATE',
          payload: c.toJson(),
          recordId: c.isarId,
          entityUuid: c.uuid,
          entityVersion: c.version,
        );
      });
      await _flushJournalEntries();
      syncV2?.triggerDebouncedSync();
    }
    return c;
  }

  /// Startup reconciliation for all customer accounts (active and soft-deleted).
  static Future<void> reconcileAllCustomerAccounts() async {
    debugPrint(
        'DBService [ACCOUNT RECONCILIATION]: Reconciling customer accounts...');
    try {
      final allCustomers = await isar.customers.where().findAll();
      for (final customer in allCustomers) {
        final isPendingValid = customer.pendingDues.isFinite &&
            !customer.pendingDues.isNaN &&
            customer.pendingDues >= 0;
        final isAdvanceValid = customer.advanceBalance.isFinite &&
            !customer.advanceBalance.isNaN &&
            customer.advanceBalance >= 0;

        if (customer.deleted) {
          if (!isPendingValid || !isAdvanceValid) {
            final state = await _computeCustomerAccountState(customer.uuid,
                existingCustomer: customer);
            customer.pendingDues = state?.newPendingDues ?? 0.0;
            customer.advanceBalance = state?.newAdvanceBalance ?? 0.0;
            _enforceCustomerMonetaryInvariants(customer);
            await isar.writeTxn(() async {
              await isar.customers.put(customer);
            });
          }
        } else {
          await recalculateCustomerAccount(customer.uuid);
        }
      }
      debugPrint(
          'DBService [ACCOUNT RECONCILIATION]: Reconciled ${allCustomers.length} customer accounts.');
    } catch (e, st) {
      debugPrint(
          'DBService [ACCOUNT RECONCILIATION]: ❌ Failed to reconcile customer accounts: $e\n$st');
    }
  }

  static Future<void> addCustomerPayment(CustomerPayment payment) async {
    if (payment.amountReceived <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }
    payment.version = 1;
    payment.isSynced = false;
    if (payment.uuid.trim().isEmpty) {
      payment.uuid = _uuid.v4();
    }
    if (payment.deviceId.trim().isEmpty || payment.deviceId == 'unknown') {
      payment.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    final state = await _computeCustomerAccountState(payment.customerUuid);
    Customer? customer;
    if (state != null) {
      customer = state.customer;
      final netCredit = payment.amountReceived;
      final currentPosition = state.newPendingDues - state.newAdvanceBalance;
      final newPosition = (currentPosition - netCredit);
      final roundedPos = (newPosition * 100).roundToDouble() / 100;
      if (roundedPos > 0) {
        customer.pendingDues = roundedPos;
        customer.advanceBalance = 0;
      } else if (roundedPos < 0) {
        customer.pendingDues = 0;
        customer.advanceBalance = roundedPos.abs();
      } else {
        customer.pendingDues = 0;
        customer.advanceBalance = 0;
      }
      payment.previousDue = state.newPendingDues;
      payment.newDue = customer.pendingDues;
      customer.updatedAt = DateTime.now();
      customer.isSynced = false;
      customer.version += 1;
    }

    await isar.writeTxn(() async {
      if (customer != null) {
        await isar.customers.put(customer);
        await _appendChangeLog(
          collection: 'Customer',
          operationType: 'UPDATE',
          payload: customer.toJson(),
          recordId: customer.isarId,
          entityUuid: customer.uuid,
          entityVersion: customer.version,
        );
      }
      await isar.customerPayments.put(payment);
      await _appendChangeLog(
        collection: 'CustomerPayment',
        operationType: 'CREATE',
        payload: payment.toJson(),
        recordId: payment.isarId,
        entityUuid: payment.uuid,
        entityVersion: payment.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteCustomerPayment(int paymentIsarId) async {
    final payment = await isar.customerPayments.get(paymentIsarId);
    if (payment == null) return;
    if (payment.deleted) return;
    final customerUuid = payment.customerUuid;

    payment.deleted = true;
    payment.updatedAt = DateTime.now();
    payment.isSynced = false;
    payment.version += 1;

    await isar.writeTxn(() async {
      await isar.customerPayments.put(payment);
      await _appendChangeLog(
        collection: 'CustomerPayment',
        operationType: 'DELETE',
        payload: payment.toJson(),
        recordId: payment.isarId,
        entityUuid: payment.uuid,
        entityVersion: payment.version,
      );
    });
    await _flushJournalEntries();
    await recalculateCustomerAccount(customerUuid);
    syncV2?.triggerDebouncedSync();
  }

  static Future<List<CustomerPayment>> getCustomerPaymentsByCustomerUuid(
      String customerUuid) async {
    return isar.customerPayments
        .filter()
        .customerUuidEqualTo(customerUuid)
        .and()
        .deletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  static Future<List<CustomerPayment>> getCustomerPaymentsByCustomerId(
      int customerId) async {
    final customer = await isar.customers.get(customerId);
    if (customer == null) {
      return [];
    }
    return getCustomerPaymentsByCustomerUuid(customer.uuid);
  }

  static Future<void> recordSale(Sale sale) async {
    // ── Pre-load all related entities BEFORE the write transaction ────────────
    // Isar 3.x does not allow reads inside write transactions.
    Sale? oldSale;
    if (sale.isarId != Isar.autoIncrement) {
      oldSale = await isar.sales.get(sale.isarId);
    }

    // Build one net stock delta per product. Editing a sale can include the
    // same product in both old and new items, so loading two product snapshots
    // and writing them independently can apply the wrong final quantity.
    final productQuantityDeltas = <String, int>{};
    if (oldSale != null) {
      for (final item in oldSale.items) {
        if (item.productUuid.isEmpty) continue;
        productQuantityDeltas[item.productUuid] =
            (productQuantityDeltas[item.productUuid] ?? 0) + item.quantity;
      }
    }
    for (final item in sale.items) {
      if (item.productUuid.isEmpty) continue;
      productQuantityDeltas[item.productUuid] =
          (productQuantityDeltas[item.productUuid] ?? 0) - item.quantity;
    }

    final saleProductsMap = <String, Product>{};
    for (final entry in productQuantityDeltas.entries) {
      if (entry.value == 0) continue;
      final product =
          await isar.products.filter().uuidEqualTo(entry.key).findFirst();
      if (product != null) {
        saleProductsMap[entry.key] = product;
      }
    }

    // Load customer for old credit sale (to restore dues)
    Customer? oldCustomer;
    if (oldSale != null &&
        oldSale.saleType == SaleType.credit &&
        oldSale.customerUuid != null) {
      oldCustomer = await isar.customers
          .filter()
          .uuidEqualTo(oldSale.customerUuid!)
          .findFirst();
    }

    // Load customer for new credit sale (to add dues)
    Customer? newCustomer;
    if (sale.saleType == SaleType.credit && sale.customerUuid != null) {
      if (oldCustomer != null && oldCustomer.uuid == sale.customerUuid) {
        newCustomer = oldCustomer;
      } else {
        newCustomer = await isar.customers
            .filter()
            .uuidEqualTo(sale.customerUuid!)
            .findFirst();
      }
    }

    // ── Mutate all entities in memory ─────────────────────────────────────────
    for (final entry in productQuantityDeltas.entries) {
      final product = saleProductsMap[entry.key];
      if (product != null) {
        product.quantity += entry.value;
        if (product.quantity < 0) product.quantity = 0;
        product.updatedAt = DateTime.now();
        product.isSynced = false;
        product.version += 1;
      }
    }

    if (oldSale != null) {
      sale.isarId = oldSale.isarId;
      sale.uuid = oldSale.uuid;
      sale.createdAt = oldSale.createdAt;
      sale.version = oldSale.version + 1;
    } else if (sale.version <= 0) {
      sale.version = 1;
    }

    sale.updatedAt = DateTime.now();
    sale.isSynced = false;
    sale.deleted = false;
    if (sale.deviceId.trim().isEmpty || sale.deviceId == 'unknown') {
      sale.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    // ── Single write transaction — all puts, no reads ──────────────────────────
    await isar.writeTxn(() async {
      for (final product in saleProductsMap.values) {
        await _putProductSafe(product);
        await _appendChangeLog(
          collection: 'Product',
          operationType: 'UPDATE',
          payload: product.toJson(),
          recordId: product.isarId,
          entityUuid: product.uuid,
          entityVersion: product.version,
        );
      }

      await isar.sales.put(sale);
      await _appendChangeLog(
        collection: 'Sale',
        operationType: oldSale == null ? 'CREATE' : 'UPDATE',
        payload: sale.toJson(),
        recordId: sale.isarId,
        entityUuid: sale.uuid,
        entityVersion: sale.version,
      );
    });
    await _flushJournalEntries();

    // Recalculate customer account balances for old and new customer
    if (oldCustomer != null) {
      await recalculateCustomerAccount(oldCustomer.uuid);
    }
    if (newCustomer != null && newCustomer.uuid != oldCustomer?.uuid) {
      await recalculateCustomerAccount(newCustomer.uuid);
    }

    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updateSale(Sale sale) async {
    sale.updatedAt = DateTime.now();
    sale.isSynced = false;
    sale.version += 1;
    if (sale.deviceId.trim().isEmpty || sale.deviceId == 'unknown') {
      sale.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }
    await isar.writeTxn(() async {
      await isar.sales.put(sale);
      await _appendChangeLog(
        collection: 'Sale',
        operationType: 'UPDATE',
        payload: sale.toJson(),
        recordId: sale.isarId,
        entityUuid: sale.uuid,
        entityVersion: sale.version,
      );
    });
    await _flushJournalEntries();
    if (sale.saleType == SaleType.credit && sale.customerUuid != null) {
      await recalculateCustomerAccount(sale.customerUuid!);
    }
    syncV2?.triggerDebouncedSync();
  }

  static Future<Sale?> getSaleById(int id) async {
    return isar.sales.get(id);
  }

  static Future<void> deleteSale(int id) async {
    // Pre-load entities BEFORE write transaction
    final sale = await isar.sales.get(id);
    if (sale == null) return;
    if (sale.deleted) return;

    final productQuantityDeltas = <String, int>{};
    for (final item in sale.items) {
      if (item.productUuid.isEmpty) continue;
      productQuantityDeltas[item.productUuid] =
          (productQuantityDeltas[item.productUuid] ?? 0) + item.quantity;
    }

    final productsMap = <String, Product>{};
    for (final entry in productQuantityDeltas.entries) {
      if (entry.value == 0) continue;
      final product =
          await isar.products.filter().uuidEqualTo(entry.key).findFirst();
      if (product != null) {
        product.quantity += entry.value;
        product.updatedAt = DateTime.now();
        product.isSynced = false;
        product.version += 1;
        productsMap[entry.key] = product;
      }
    }

    sale.deleted = true;
    sale.updatedAt = DateTime.now();
    sale.isSynced = false;
    sale.version += 1;

    await isar.writeTxn(() async {
      for (final product in productsMap.values) {
        await _putProductSafe(product);
        await _appendChangeLog(
          collection: 'Product',
          operationType: 'UPDATE',
          payload: product.toJson(),
          recordId: product.isarId,
          entityUuid: product.uuid,
          entityVersion: product.version,
        );
      }
      await isar.sales.put(sale);
      await _appendChangeLog(
        collection: 'Sale',
        operationType: 'DELETE',
        payload: sale.toJson(),
        recordId: sale.isarId,
        entityUuid: sale.uuid,
        entityVersion: sale.version,
      );
    });
    await _flushJournalEntries();
    if (sale.saleType == SaleType.credit && sale.customerUuid != null) {
      await recalculateCustomerAccount(sale.customerUuid!);
    }
    syncV2?.triggerDebouncedSync();
  }

  static Future<List<Sale>> getAllSales() async {
    return isar.sales.filter().deletedEqualTo(false).sortByDateDesc().findAll();
  }

  static Future<void> deleteSaleAndRestoreStock(String saleUuid) async {
    // Pre-load entities BEFORE write transaction
    final sale = await isar.sales.filter().uuidEqualTo(saleUuid).findFirst();
    if (sale == null) return;
    if (sale.deleted) return;

    final Map<String, Product> productsMap = {};
    for (final item in sale.items) {
      final p = await isar.products
          .filter()
          .uuidEqualTo(item.productUuid)
          .findFirst();
      if (p != null) productsMap[item.productUuid] = p;
    }

    // Mutate in memory
    for (final item in sale.items) {
      final p = productsMap[item.productUuid];
      if (p != null) {
        p.quantity += item.quantity;
        p.updatedAt = DateTime.now();
        p.isSynced = false;
        p.version += 1;
      }
    }
    sale.deleted = true;
    sale.updatedAt = DateTime.now();
    sale.isSynced = false;
    sale.version += 1;

    await isar.writeTxn(() async {
      for (final product in productsMap.values) {
        await _putProductSafe(product);
        await _appendChangeLog(
          collection: 'Product',
          operationType: 'UPDATE',
          payload: product.toJson(),
          recordId: product.isarId,
          entityUuid: product.uuid,
          entityVersion: product.version,
        );
      }
      await isar.sales.put(sale);
      await _appendChangeLog(
        collection: 'Sale',
        operationType: 'DELETE',
        payload: sale.toJson(),
        recordId: sale.isarId,
        entityUuid: sale.uuid,
        entityVersion: sale.version,
      );
    });
    await _flushJournalEntries();
    if (sale.saleType == SaleType.credit && sale.customerUuid != null) {
      await recalculateCustomerAccount(sale.customerUuid!);
    }
    syncV2?.triggerDebouncedSync();
  }

  static Future<List<SaleItem>> getSaleItemsForSaleId(int saleId) async {
    final sale = await isar.sales.get(saleId);
    return sale?.items.toList() ?? [];
  }

  static Future<void> updateSalePayment({
    String? saleUuid,
    int? saleId,
    required double newAmountReceived,
  }) async {
    // Pre-load entities BEFORE write transaction
    Sale? sale;
    if (saleUuid != null) {
      sale = await isar.sales.filter().uuidEqualTo(saleUuid).findFirst();
    } else if (saleId != null) {
      sale = await isar.sales.get(saleId);
    }
    if (sale == null) return;

    sale.amountReceived = newAmountReceived;
    sale.updatedAt = DateTime.now();
    sale.isSynced = false;
    sale.version += 1;

    await isar.writeTxn(() async {
      await isar.sales.put(sale!);
      await _appendChangeLog(
        collection: 'Sale',
        operationType: 'UPDATE',
        payload: sale.toJson(),
        recordId: sale.isarId,
        entityUuid: sale.uuid,
        entityVersion: sale.version,
      );
    });
    await _flushJournalEntries();
    if (sale.saleType == SaleType.credit && sale.customerUuid != null) {
      await recalculateCustomerAccount(sale.customerUuid!);
    }
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updateSalePaymentByUuid({
    required String saleUuid,
    required double newAmountReceived,
  }) async {
    await updateSalePayment(
      saleUuid: saleUuid,
      newAmountReceived: newAmountReceived,
    );
  }

  static Future<void> updateCustomerDues(int id, double newDue) async {
    final customer = await isar.customers.get(id);
    if (customer == null) return;
    final safeDue = (!newDue.isFinite || newDue.isNaN) ? 0.0 : newDue;
    if (safeDue >= 0) {
      customer.pendingDues = safeDue;
      customer.advanceBalance = 0;
    } else {
      customer.pendingDues = 0;
      customer.advanceBalance = safeDue.abs();
    }
    _enforceCustomerMonetaryInvariants(customer);
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;
    customer.version += 1;
    await isar.writeTxn(() async {
      await isar.customers.put(customer);
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'UPDATE',
        payload: customer.toJson(),
        recordId: customer.isarId,
        entityUuid: customer.uuid,
        entityVersion: customer.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updateCustomerDuesByUuid(
    String customerUuid,
    double newDue,
  ) async {
    final customer =
        await isar.customers.filter().uuidEqualTo(customerUuid).findFirst();
    if (customer == null) return;
    final safeDue = (!newDue.isFinite || newDue.isNaN) ? 0.0 : newDue;
    if (safeDue >= 0) {
      customer.pendingDues = safeDue;
      customer.advanceBalance = 0;
    } else {
      customer.pendingDues = 0;
      customer.advanceBalance = safeDue.abs();
    }
    _enforceCustomerMonetaryInvariants(customer);
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;
    customer.version += 1;
    await isar.writeTxn(() async {
      await isar.customers.put(customer);
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'UPDATE',
        payload: customer.toJson(),
        recordId: customer.isarId,
        entityUuid: customer.uuid,
        entityVersion: customer.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> addSupplier(Supplier supplier) async {
    final now = DateTime.now();
    supplier.createdAt = now;
    supplier.updatedAt = now;
    supplier.deleted = false;
    supplier.version = 1;
    supplier.isSynced = false;
    if (supplier.deviceId.trim().isEmpty || supplier.deviceId == 'unknown') {
      supplier.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }
    await isar.writeTxn(() async {
      await isar.suppliers.put(supplier);
      await _appendChangeLog(
        collection: 'Supplier',
        operationType: 'CREATE',
        payload: supplier.toJson(),
        recordId: supplier.isarId,
        entityUuid: supplier.uuid,
        entityVersion: supplier.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updateSupplier(Supplier supplier) async {
    supplier.updatedAt = DateTime.now();
    supplier.isSynced = false;
    supplier.version += 1;
    if (supplier.deviceId.trim().isEmpty || supplier.deviceId == 'unknown') {
      supplier.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }
    await isar.writeTxn(() async {
      await isar.suppliers.put(supplier);
      await _appendChangeLog(
        collection: 'Supplier',
        operationType: 'UPDATE',
        payload: supplier.toJson(),
        recordId: supplier.isarId,
        entityUuid: supplier.uuid,
        entityVersion: supplier.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteSupplier(String supplierUuid) async {
    final supplier =
        await isar.suppliers.filter().uuidEqualTo(supplierUuid).findFirst();
    if (supplier == null) return;
    supplier.deleted = true;
    supplier.updatedAt = DateTime.now();
    supplier.isSynced = false;
    supplier.version += 1;
    await isar.writeTxn(() async {
      await isar.suppliers.put(supplier);
      await _appendChangeLog(
        collection: 'Supplier',
        operationType: 'DELETE',
        payload: supplier.toJson(),
        recordId: supplier.isarId,
        entityUuid: supplier.uuid,
        entityVersion: supplier.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteSupplierByIsarId(int id) async {
    final supplier = await isar.suppliers.get(id);
    if (supplier == null) return;
    supplier.deleted = true;
    supplier.updatedAt = DateTime.now();
    supplier.isSynced = false;
    supplier.version += 1;
    await isar.writeTxn(() async {
      await isar.suppliers.put(supplier);
      await _appendChangeLog(
        collection: 'Supplier',
        operationType: 'DELETE',
        payload: supplier.toJson(),
        recordId: supplier.isarId,
        entityUuid: supplier.uuid,
        entityVersion: supplier.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<List<Supplier>> getSuppliers() async {
    return isar.suppliers.filter().deletedEqualTo(false).findAll();
  }

  static Future<List<Supplier>> getAllSuppliers() async {
    return isar.suppliers
        .filter()
        .deletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<void> addPurchase(Purchase purchase) async {
    final now = DateTime.now();
    purchase.createdAt = now;
    purchase.updatedAt = now;
    purchase.deleted = false;
    purchase.version = 1;
    purchase.isSynced = false;
    if (purchase.deviceId.trim().isEmpty || purchase.deviceId == 'unknown') {
      purchase.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    final productQuantityDeltas = <String, int>{};
    for (final item in purchase.items) {
      if (item.productUuid.isEmpty) continue;
      productQuantityDeltas[item.productUuid] =
          (productQuantityDeltas[item.productUuid] ?? 0) + item.quantity;
    }

    final productsMap = <String, Product>{};
    for (final entry in productQuantityDeltas.entries) {
      if (entry.value == 0) continue;
      final product =
          await isar.products.filter().uuidEqualTo(entry.key).findFirst();
      if (product != null) {
        product.quantity += entry.value;
        product.updatedAt = DateTime.now();
        product.isSynced = false;
        product.version += 1;
        productsMap[entry.key] = product;
      }
    }

    await isar.writeTxn(() async {
      await isar.purchases.put(purchase);
      await _appendChangeLog(
        collection: 'Purchase',
        operationType: 'CREATE',
        payload: purchase.toJson(),
        recordId: purchase.isarId,
        entityUuid: purchase.uuid,
        entityVersion: purchase.version,
      );
      for (final product in productsMap.values) {
        await _putProductSafe(product);
        await _appendChangeLog(
          collection: 'Product',
          operationType: 'UPDATE',
          payload: product.toJson(),
          recordId: product.isarId,
          entityUuid: product.uuid,
          entityVersion: product.version,
        );
      }
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updatePurchase(Purchase purchase) async {
    final oldPurchase = await isar.purchases.get(purchase.isarId);
    final productQuantityDeltas = <String, int>{};

    if (oldPurchase != null) {
      for (final item in oldPurchase.items) {
        if (item.productUuid.isEmpty) continue;
        productQuantityDeltas[item.productUuid] =
            (productQuantityDeltas[item.productUuid] ?? 0) - item.quantity;
      }
    }
    for (final item in purchase.items) {
      if (item.productUuid.isEmpty) continue;
      productQuantityDeltas[item.productUuid] =
          (productQuantityDeltas[item.productUuid] ?? 0) + item.quantity;
    }

    final productsMap = <String, Product>{};
    for (final entry in productQuantityDeltas.entries) {
      if (entry.value == 0) continue;
      final product =
          await isar.products.filter().uuidEqualTo(entry.key).findFirst();
      if (product != null) {
        product.quantity += entry.value;
        if (product.quantity < 0) product.quantity = 0;
        product.updatedAt = DateTime.now();
        product.isSynced = false;
        product.version += 1;
        productsMap[entry.key] = product;
      }
    }

    purchase.updatedAt = DateTime.now();
    purchase.isSynced = false;
    purchase.version = (oldPurchase?.version ?? 0) + 1;
    if (purchase.deviceId.trim().isEmpty || purchase.deviceId == 'unknown') {
      purchase.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    await isar.writeTxn(() async {
      for (final product in productsMap.values) {
        await _putProductSafe(product);
        await _appendChangeLog(
          collection: 'Product',
          operationType: 'UPDATE',
          payload: product.toJson(),
          recordId: product.isarId,
          entityUuid: product.uuid,
          entityVersion: product.version,
        );
      }
      await isar.purchases.put(purchase);
      await _appendChangeLog(
        collection: 'Purchase',
        operationType: 'UPDATE',
        payload: purchase.toJson(),
        recordId: purchase.isarId,
        entityUuid: purchase.uuid,
        entityVersion: purchase.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deletePurchase(int id) async {
    final purchase = await isar.purchases.get(id);
    if (purchase == null || purchase.deleted) return;

    final productQuantityDeltas = <String, int>{};
    for (final item in purchase.items) {
      if (item.productUuid.isEmpty) continue;
      productQuantityDeltas[item.productUuid] =
          (productQuantityDeltas[item.productUuid] ?? 0) - item.quantity;
    }

    final productsMap = <String, Product>{};
    for (final entry in productQuantityDeltas.entries) {
      if (entry.value == 0) continue;
      final product =
          await isar.products.filter().uuidEqualTo(entry.key).findFirst();
      if (product != null) {
        product.quantity += entry.value;
        if (product.quantity < 0) product.quantity = 0;
        product.updatedAt = DateTime.now();
        product.isSynced = false;
        product.version += 1;
        productsMap[entry.key] = product;
      }
    }

    purchase.deleted = true;
    purchase.updatedAt = DateTime.now();
    purchase.isSynced = false;
    purchase.version += 1;

    await isar.writeTxn(() async {
      for (final product in productsMap.values) {
        await _putProductSafe(product);
        await _appendChangeLog(
          collection: 'Product',
          operationType: 'UPDATE',
          payload: product.toJson(),
          recordId: product.isarId,
          entityUuid: product.uuid,
          entityVersion: product.version,
        );
      }
      await isar.purchases.put(purchase);
      await _appendChangeLog(
        collection: 'Purchase',
        operationType: 'DELETE',
        payload: purchase.toJson(),
        recordId: purchase.isarId,
        entityUuid: purchase.uuid,
        entityVersion: purchase.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<List<Purchase>> getAllPurchases() async {
    return isar.purchases
        .filter()
        .deletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  static Future<List<Purchase>> getPurchasesBySupplier(
      String supplierUuid) async {
    return isar.purchases
        .filter()
        .supplierUuidEqualTo(supplierUuid)
        .and()
        .deletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  static Future<void> addSupplierPayment(SupplierPayment payment) async {
    payment.version = 1;
    payment.isSynced = false;
    if (payment.uuid.trim().isEmpty) {
      payment.uuid = _uuid.v4();
    }
    if (payment.deviceId.trim().isEmpty || payment.deviceId == 'unknown') {
      payment.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    await isar.writeTxn(() async {
      await isar.supplierPayments.put(payment);
      await _appendChangeLog(
        collection: 'SupplierPayment',
        operationType: 'CREATE',
        payload: payment.toJson(),
        recordId: payment.isarId,
        entityUuid: payment.uuid,
        entityVersion: payment.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteSupplierPayment(int paymentIsarId) async {
    final payment = await isar.supplierPayments.get(paymentIsarId);
    if (payment == null || payment.deleted) return;

    payment.deleted = true;
    payment.updatedAt = DateTime.now();
    payment.isSynced = false;
    payment.version += 1;

    await isar.writeTxn(() async {
      await isar.supplierPayments.put(payment);
      await _appendChangeLog(
        collection: 'SupplierPayment',
        operationType: 'DELETE',
        payload: payment.toJson(),
        recordId: payment.isarId,
        entityUuid: payment.uuid,
        entityVersion: payment.version,
      );
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<List<SupplierPayment>> getSupplierPayments(
      String supplierUuid) async {
    return isar.supplierPayments
        .filter()
        .supplierUuidEqualTo(supplierUuid)
        .and()
        .deletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  static Future<List<SupplierPayment>> getAllSupplierPayments() async {
    return isar.supplierPayments
        .filter()
        .deletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  static Future<void> deleteInvalidSales() async {
    final sales = await isar.sales.where().findAll();
    await isar.writeTxn(() async {
      for (final sale in sales) {
        if (!sale.totalAmount.isFinite || sale.totalAmount.isNaN) {
          sale.deleted = true;
          sale.updatedAt = DateTime.now();
          sale.isSynced = false;
          sale.version += 1;
          await isar.sales.put(sale);
          await _appendChangeLog(
            collection: 'Sale',
            operationType: 'DELETE',
            payload: sale.toJson(),
            recordId: sale.isarId,
            entityUuid: sale.uuid,
            entityVersion: sale.version,
          );
        }
      }
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<double> getTotalSales() async {
    final sales = await getAllSales();
    double total = 0.0;
    for (final sale in sales) {
      if (sale.totalAmount.isFinite && !sale.totalAmount.isNaN) {
        total += sale.totalAmount;
      }
    }
    return total;
  }

  static Future<void> patchMissingAmountReceived() async {
    final sales = await isar.sales.where().findAll();
    await isar.writeTxn(() async {
      for (final sale in sales) {
        if (sale.amountReceived == 0) {
          sale.amountReceived =
              (sale.saleType == SaleType.cash) ? sale.totalAmount : 0;
          sale.updatedAt = DateTime.now();
          sale.isSynced = false;
          sale.version += 1;
          await isar.sales.put(sale);
          await _appendChangeLog(
            collection: 'Sale',
            operationType: 'UPDATE',
            payload: sale.toJson(),
            recordId: sale.isarId,
            entityUuid: sale.uuid,
            entityVersion: sale.version,
          );
        }
      }
    });
    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> cleanupDuplicateAndStalePeers() async {
    debugPrint(
        'DBService [CLEANUP]: Starting peer cleanup and migration (isarHash=${isar.hashCode})...');
    try {
      final peers = await isar.peerStates.where().findAll();
      final Map<String, PeerState> uniquePeersByIp = {};
      final List<int> idsToDelete = [];

      // Sort peers by lastSeen descending so we keep the most recently seen one
      final sortedPeers = List<PeerState>.from(peers);
      sortedPeers.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

      for (final peer in sortedPeers) {
        if (uniquePeersByIp.containsKey(peer.peerIp)) {
          // This is a duplicate peer with the same IP but a different peerId (likely from a previous app start with a different transient device ID)
          idsToDelete.add(peer.id);
          debugPrint(
              'DBService [CLEANUP]: Found duplicate peer record to delete: id=${peer.id}, peerId=${peer.peerId}, ip=${peer.peerIp}');
        } else {
          uniquePeersByIp[peer.peerIp] = peer;
        }
      }

      // ✅ FIX: Use 30-day threshold (matching compaction retention) instead of 24h.
      // Deleting peers after 24h on every app restart wipes their lastPulledChangeSeq,
      // forcing a full re-sync every time a device is offline for more than a day.
      final cutoff = DateTime.now()
          .subtract(const Duration(days: 30))
          .millisecondsSinceEpoch;
      for (final peer in sortedPeers) {
        if (peer.lastSeen < cutoff && !idsToDelete.contains(peer.id)) {
          idsToDelete.add(peer.id);
          debugPrint(
              'DBService [CLEANUP]: Found stale peer record to delete (last seen > 30d ago): id=${peer.id}, peerId=${peer.peerId}, ip=${peer.peerIp}');
        }
      }

      if (idsToDelete.isNotEmpty) {
        await isar.writeTxn(() async {
          await isar.peerStates.deleteAll(idsToDelete);
        });
        debugPrint(
            'DBService [CLEANUP]: Successfully deleted ${idsToDelete.length} stale/duplicate peer records (isarHash=${isar.hashCode})');
      } else {
        debugPrint(
            'DBService [CLEANUP]: No stale/duplicate peer records found to clean up');
      }
    } catch (e, st) {
      debugPrint(
          'DBService [CLEANUP]: ❌ Failed to run peer cleanup migration: $e\n$st');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GODOWN STOCK & MOVEMENTS
  // ─────────────────────────────────────────────────────────────────────────────

  static Future<List<GodownItem>> getGodownItems() async {
    return isar.godownItems.filter().deletedEqualTo(false).findAll();
  }

  static Future<GodownItem?> getGodownItemByUuid(String uuid) async {
    return isar.godownItems
        .filter()
        .uuidEqualTo(uuid)
        .and()
        .deletedEqualTo(false)
        .findFirst();
  }

  static Future<void> addGodownItem(GodownItem item) async {
    final now = DateTime.now();
    item.createdAt = now;
    item.updatedAt = now;
    item.deleted = false;
    item.version = 1;
    item.isSynced = false;
    if (item.deviceId.trim().isEmpty || item.deviceId == 'unknown') {
      item.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    final movement = GodownMovement.create(
      godownItemUuid: item.uuid,
      godownItemName: item.name,
      movementType: GodownMovementType.stockAdded,
      quantityChanged: item.quantity,
      remainingQuantity: item.quantity,
      note: 'Initial godown stock added',
    );

    await isar.writeTxn(() async {
      await isar.godownItems.put(item);
      await _appendChangeLog(
        collection: 'GodownItem',
        operationType: 'CREATE',
        payload: item.toJson(),
        recordId: item.isarId,
        entityUuid: item.uuid,
        entityVersion: item.version,
      );
      await isar.godownMovements.put(movement);
      await _appendChangeLog(
        collection: 'GodownMovement',
        operationType: 'CREATE',
        payload: movement.toJson(),
        recordId: movement.isarId,
        entityUuid: movement.uuid,
        entityVersion: 1,
      );
    });

    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updateGodownItem(GodownItem item) async {
    item.updatedAt = DateTime.now();
    item.isSynced = false;
    item.version += 1;
    if (item.deviceId.trim().isEmpty || item.deviceId == 'unknown') {
      item.deviceId = syncV2?.deviceId ?? _kUnknownDevice;
    }

    final movement = GodownMovement.create(
      godownItemUuid: item.uuid,
      godownItemName: item.name,
      movementType: GodownMovementType.manualAdjustment,
      quantityChanged: 0,
      remainingQuantity: item.quantity,
      note: 'Godown item details updated',
    );

    await isar.writeTxn(() async {
      await isar.godownItems.put(item);
      await _appendChangeLog(
        collection: 'GodownItem',
        operationType: 'UPDATE',
        payload: item.toJson(),
        recordId: item.isarId,
        entityUuid: item.uuid,
        entityVersion: item.version,
      );
      await isar.godownMovements.put(movement);
      await _appendChangeLog(
        collection: 'GodownMovement',
        operationType: 'CREATE',
        payload: movement.toJson(),
        recordId: movement.isarId,
        entityUuid: movement.uuid,
        entityVersion: 1,
      );
    });

    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> adjustGodownQuantity({
    required String godownItemUuid,
    required int deltaQuantity,
    String? note,
  }) async {
    final item = await isar.godownItems
        .filter()
        .uuidEqualTo(godownItemUuid)
        .and()
        .deletedEqualTo(false)
        .findFirst();

    if (item == null) throw StateError('Godown item not found.');

    final newQty = item.quantity + deltaQuantity;
    if (newQty < 0) {
      throw StateError(
          'Cannot reduce stock below zero. Current: ${item.quantity}');
    }

    item.quantity = newQty;
    item.updatedAt = DateTime.now();
    item.isSynced = false;
    item.version += 1;

    final movementType = deltaQuantity > 0
        ? GodownMovementType.quantityIncreased
        : GodownMovementType.quantityDecreased;

    final movement = GodownMovement.create(
      godownItemUuid: item.uuid,
      godownItemName: item.name,
      movementType: movementType,
      quantityChanged: deltaQuantity,
      remainingQuantity: item.quantity,
      note: note ?? (deltaQuantity > 0 ? 'Stock increased' : 'Stock decreased'),
    );

    await isar.writeTxn(() async {
      await isar.godownItems.put(item);
      await _appendChangeLog(
        collection: 'GodownItem',
        operationType: 'UPDATE',
        payload: item.toJson(),
        recordId: item.isarId,
        entityUuid: item.uuid,
        entityVersion: item.version,
      );
      await isar.godownMovements.put(movement);
      await _appendChangeLog(
        collection: 'GodownMovement',
        operationType: 'CREATE',
        payload: movement.toJson(),
        recordId: movement.isarId,
        entityUuid: movement.uuid,
        entityVersion: 1,
      );
    });

    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteGodownItem(String godownItemUuid) async {
    final item = await isar.godownItems
        .filter()
        .uuidEqualTo(godownItemUuid)
        .and()
        .deletedEqualTo(false)
        .findFirst();

    if (item == null) return;

    // Pre-load linked product BEFORE writeTxn (Isar 3.x rule)
    Product? linkedProduct;
    if (item.productUuid != null && item.productUuid!.isNotEmpty) {
      linkedProduct = await isar.products
          .filter()
          .uuidEqualTo(item.productUuid!)
          .and()
          .deletedEqualTo(false)
          .findFirst();
    }

    final remainingQty = item.quantity;
    item.deleted = true;
    item.updatedAt = DateTime.now();
    item.isSynced = false;
    item.version += 1;

    final movement = GodownMovement.create(
      godownItemUuid: item.uuid,
      godownItemName: item.name,
      movementType: GodownMovementType.stockRemoved,
      quantityChanged: -remainingQty,
      remainingQuantity: 0,
      note: linkedProduct != null
          ? 'Stock removed from godown and returned to shop inventory'
          : 'Stock item removed from godown',
    );

    await isar.writeTxn(() async {
      await isar.godownItems.put(item);
      await _appendChangeLog(
        collection: 'GodownItem',
        operationType: 'DELETE',
        payload: item.toJson(),
        recordId: item.isarId,
        entityUuid: item.uuid,
        entityVersion: item.version,
      );
      await isar.godownMovements.put(movement);
      await _appendChangeLog(
        collection: 'GodownMovement',
        operationType: 'CREATE',
        payload: movement.toJson(),
        recordId: movement.isarId,
        entityUuid: movement.uuid,
        entityVersion: 1,
      );

      // Restore stock to linked inventory product
      if (linkedProduct != null && remainingQty > 0) {
        linkedProduct.quantity += remainingQty;
        linkedProduct.updatedAt = DateTime.now();
        linkedProduct.isSynced = false;
        linkedProduct.version += 1;
        await isar.products.put(linkedProduct);
        await _appendChangeLog(
          collection: 'Product',
          operationType: 'UPDATE',
          payload: linkedProduct.toJson(),
          recordId: linkedProduct.isarId,
          entityUuid: linkedProduct.uuid,
          entityVersion: linkedProduct.version,
        );
      }
    });

    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> transferGodownToShop({
    required String godownItemUuid,
    required int transferQuantity,
  }) async {
    if (transferQuantity <= 0) {
      throw ArgumentError('Transfer quantity must be greater than zero.');
    }

    // Pre-load entities BEFORE write transaction (Isar 3.x restriction)
    final godownItem = await isar.godownItems
        .filter()
        .uuidEqualTo(godownItemUuid)
        .and()
        .deletedEqualTo(false)
        .findFirst();

    if (godownItem == null) {
      throw StateError('Godown item not found.');
    }

    if (godownItem.quantity < transferQuantity) {
      throw StateError(
          'Cannot transfer $transferQuantity units. Only ${godownItem.quantity} units available in godown.');
    }

    // Check if matching product already exists in shop inventory (case-insensitive name match)
    final existingProducts =
        await isar.products.filter().deletedEqualTo(false).findAll();
    Product? targetProduct;
    for (final p in existingProducts) {
      if (p.name.trim().toLowerCase() == godownItem.name.trim().toLowerCase()) {
        targetProduct = p;
        break;
      }
    }

    final isNewProduct = (targetProduct == null);
    final String deviceId = syncV2?.deviceId ?? _kUnknownDevice;

    if (targetProduct == null) {
      targetProduct = Product.create(
        name: godownItem.name.trim(),
        salePrice: godownItem.unitCost > 0 ? godownItem.unitCost * 1.2 : 0,
        purchasePrice: godownItem.unitCost,
        quantity: transferQuantity,
        deviceId: deviceId,
      );
    } else {
      targetProduct.quantity += transferQuantity;
      targetProduct.updatedAt = DateTime.now();
      targetProduct.isSynced = false;
      targetProduct.version += 1;
    }

    // Mutate godown item
    godownItem.quantity -= transferQuantity;
    godownItem.updatedAt = DateTime.now();
    godownItem.isSynced = false;
    godownItem.version += 1;

    // Create movement audit record
    final movement = GodownMovement.create(
      godownItemUuid: godownItem.uuid,
      godownItemName: godownItem.name,
      movementType: GodownMovementType.transferToShop,
      quantityChanged: -transferQuantity,
      remainingQuantity: godownItem.quantity,
      referenceId: targetProduct.uuid,
      note: 'Transferred $transferQuantity units to shop inventory',
    );

    // Single atomic write transaction — both puts together
    await isar.writeTxn(() async {
      await isar.godownItems.put(godownItem);
      await _appendChangeLog(
        collection: 'GodownItem',
        operationType: 'UPDATE',
        payload: godownItem.toJson(),
        recordId: godownItem.isarId,
        entityUuid: godownItem.uuid,
        entityVersion: godownItem.version,
      );

      await _putProductSafe(targetProduct!);
      await _appendChangeLog(
        collection: 'Product',
        operationType: isNewProduct ? 'CREATE' : 'UPDATE',
        payload: targetProduct.toJson(),
        recordId: targetProduct.isarId,
        entityUuid: targetProduct.uuid,
        entityVersion: targetProduct.version,
      );

      await isar.godownMovements.put(movement);
      await _appendChangeLog(
        collection: 'GodownMovement',
        operationType: 'CREATE',
        payload: movement.toJson(),
        recordId: movement.isarId,
        entityUuid: movement.uuid,
        entityVersion: 1,
      );
    });

    await _flushJournalEntries();
    syncV2?.triggerDebouncedSync();
  }

  static Future<List<GodownMovement>> getGodownMovements(
      String godownItemUuid) async {
    return isar.godownMovements
        .filter()
        .godownItemUuidEqualTo(godownItemUuid)
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<List<GodownMovement>> getAllGodownMovements() async {
    return isar.godownMovements.where().sortByCreatedAtDesc().findAll();
  }

  static Future<void> _backfillTable<T>({
    required String entityType,
    required ChangeJournal journal,
    required Future<List<T>> Function() fetchRows,
    required String Function(T row) entityId,
    required int Function(T row) entityVersion,
    required Map<String, dynamic> Function(T row) payload,
  }) async {
    // All reads BEFORE the write transaction — Isar 3.x forbids reads in writeTxn
    final existingCreates = await isar.syncChangeLogs
        .filter()
        .entityTypeEqualTo(entityType)
        .and()
        .operationEqualTo('CREATE')
        .findAll();
    final existingEntityIds =
        existingCreates.map((entry) => entry.entityId).toSet();

    final rows = await fetchRows();
    int appended = 0;

    for (final row in rows) {
      final id = entityId(row);
      if (id.isEmpty || existingEntityIds.contains(id)) {
        continue;
      }
      // journal.append() manages its own writeTxn internally
      await journal.append(
        entityType: entityType,
        entityId: id,
        operation: 'CREATE',
        entityVersion: entityVersion(row),
        payload: payload(row),
      );
      appended++;
    }

    debugPrint(
        'DBService [V2 BACKFILL]: $entityType appended $appended CREATE entr${appended == 1 ? 'y' : 'ies'}');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: pending v2 journal entry (written AFTER entity writeTxn commits)
// ─────────────────────────────────────────────────────────────────────────────

class _JournalEntry {
  final String entityType;
  final String entityId;
  final String operation;
  final int entityVersion;
  final Map<String, dynamic> payload;

  const _JournalEntry({
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.entityVersion,
    required this.payload,
  });
}

class _CustomerAccountEvent {
  final Sale? sale;
  final CustomerPayment? payment;
  final DateTime date;
  final int isarId;

  _CustomerAccountEvent.sale(Sale sale)
      : sale = sale,
        payment = null,
        date = sale.date,
        isarId = sale.isarId;

  _CustomerAccountEvent.payment(CustomerPayment payment)
      : sale = null,
        payment = payment,
        date = payment.date,
        isarId = payment.isarId;
}

class _CustomerAccountState {
  final Customer customer;
  final double newPendingDues;
  final double newAdvanceBalance;

  const _CustomerAccountState({
    required this.customer,
    required this.newPendingDues,
    required this.newAdvanceBalance,
  });
}
