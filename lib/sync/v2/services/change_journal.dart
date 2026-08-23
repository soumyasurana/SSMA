import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/sync_change_log.dart';

/// The append-only change journal.
///
/// Every mutation to a synchronized entity MUST call [append] inside the
/// same Isar write transaction as the entity write. This guarantees that no
/// mutation is ever lost — if the transaction fails, neither the entity write
/// nor the journal entry is persisted.
///
/// The [changeSeq] increments atomically inside the Isar write transaction,
/// preventing race conditions between concurrent writes.
///
/// Design principles:
///   • Append-only: journal records are never modified.
///   • Ordered: [changeSeq] is the only reliable ordering signal.
///   • Self-contained: each entry carries the full entity snapshot in [payload].
///   • Idempotent: duplicate [changeId] entries are silently ignored on insert.
class ChangeJournal {
  final Isar isar;
  final String localDeviceId;

  static const _uuid = Uuid();

  ChangeJournal({required this.isar, required this.localDeviceId});

  // -----------------------------------------------------------------------
  // Public API
  // -----------------------------------------------------------------------

  /// Appends a new change record.
  ///
  /// MUST be called from within an active [isar.writeTxn] block.
  /// The [changeId] is generated automatically (UUID v4).
  ///
  /// Returns the assigned [changeSeq].
  Future<int> append({
    required String entityType,
    required String entityId,
    required String operation, // 'CREATE' | 'UPDATE' | 'DELETE'
    required int entityVersion,
    required Map<String, dynamic> payload,
    String? originDeviceId,
  }) async {
    // All reads and the write are inside one writeTxn so this method is
    // self-contained and can be called from any context (including outside an
    // existing transaction). Isar 3.x forbids reads inside a write transaction
    // that was started externally, so callers must NOT wrap this in their own
    // writeTxn.
    int nextSeq = 0;
    await isar.writeTxn(() async {
      final maxLog =
          await isar.syncChangeLogs.where().sortByChangeSeqDesc().findFirst();
      nextSeq = (maxLog?.changeSeq ?? 0) + 1;

      // Optional chain-of-custody: SHA-256 of the previous change for this entity
      final prevChange = await isar.syncChangeLogs
          .filter()
          .entityIdEqualTo(entityId)
          .sortByChangeSeqDesc()
          .findFirst();
      final previousHash =
          prevChange != null ? _sha256(jsonEncode(prevChange.toJson())) : null;

      final log = SyncChangeLog()
        ..changeId = _uuid.v4()
        ..changeSeq = nextSeq
        ..entityType = entityType
        ..entityId = entityId
        ..operation = operation
        ..entityVersion = entityVersion
        ..originDeviceId = originDeviceId ?? localDeviceId
        ..timestampMs = DateTime.now().millisecondsSinceEpoch
        ..payload = jsonEncode(payload)
        ..previousChangeHash = previousHash
        ..acknowledged = false;

      await isar.syncChangeLogs.put(log);
    });
    debugPrint(
        '[ChangeJournal]: appended seq=$nextSeq type=$entityType op=$operation entity=$entityId');
    return nextSeq;
  }

  /// Appends a remote change received from a peer.
  ///
  /// This self-contained helper is safe to call outside an existing
  /// transaction. [ChangeProcessor] uses [buildRemoteEntry] + [putRemoteEntry]
  /// instead so it can apply the entity row and journal row in one transaction
  /// without doing extra journal reads inside that transaction.
  ///
  /// Returns false if this change was already recorded (duplicate), true if applied.
  Future<bool> appendRemote(SyncChangeLog remote) async {
    final existing = await isar.syncChangeLogs
        .filter()
        .changeIdEqualTo(remote.changeId)
        .findFirst();
    if (existing != null) {
      debugPrint(
          '[ChangeJournal]: duplicate changeId=${remote.changeId}, skipping');
      return false;
    }

    final nextSeq = await getNextSeq();
    final stored = buildRemoteEntry(remote, localSeq: nextSeq);

    await isar.writeTxn(() => isar.syncChangeLogs.put(stored));
    return true;
  }

  /// Returns the next local journal sequence number.
  Future<int> getNextSeq() async {
    final maxLog =
        await isar.syncChangeLogs.where().sortByChangeSeqDesc().findFirst();
    return (maxLog?.changeSeq ?? 0) + 1;
  }

  /// Builds the local journal representation of a remote change.
  ///
  /// The remote [changeId] is preserved for idempotency, while [changeSeq] is
  /// assigned from this device's journal because sync cursors are per-peer
  /// positions in the serving device's journal.
  SyncChangeLog buildRemoteEntry(SyncChangeLog remote,
      {required int localSeq}) {
    return SyncChangeLog()
      ..changeId = remote.changeId
      ..changeSeq = localSeq
      ..entityType = remote.entityType
      ..entityId = remote.entityId
      ..operation = remote.operation
      ..entityVersion = remote.entityVersion
      ..originDeviceId = remote.originDeviceId
      ..timestampMs = remote.timestampMs
      ..payload = remote.payload
      ..previousChangeHash = remote.previousChangeHash
      ..acknowledged = true;
  }

  /// Stores a prepared remote journal entry.
  ///
  /// Call this from inside the same write transaction that applies the entity
  /// change so a received change never lands half-applied.
  Future<void> putRemoteEntry(SyncChangeLog stored) {
    return isar.syncChangeLogs.put(stored);
  }

  // -----------------------------------------------------------------------
  // Query helpers
  // -----------------------------------------------------------------------

  /// Returns all changes with [changeSeq] > [sinceSeq], ordered ascending.
  /// Paginated by [limit].
  Future<List<SyncChangeLog>> getChangesSince(int sinceSeq, {int limit = 200}) {
    return isar.syncChangeLogs
        .filter()
        .changeSeqGreaterThan(sinceSeq)
        .sortByChangeSeq()
        .limit(limit)
        .findAll();
  }

  /// Returns only locally originated changes with [changeSeq] > [sinceSeq].
  ///
  /// Useful for diagnostics that need to distinguish local writes from peer
  /// replay entries. The sync transport itself sends the full journal through
  /// [getChangesSince] so changes can propagate transitively across peers.
  Future<List<SyncChangeLog>> getLocalChangesSince(int sinceSeq,
      {int limit = 200}) {
    return isar.syncChangeLogs
        .filter()
        .originDeviceIdEqualTo(localDeviceId)
        .and()
        .changeSeqGreaterThan(sinceSeq)
        .sortByChangeSeq()
        .limit(limit)
        .findAll();
  }

  /// Returns the number of locally originated changes newer than [sinceSeq].
  Future<int> countLocalChangesSince(int sinceSeq) {
    return isar.syncChangeLogs
        .filter()
        .originDeviceIdEqualTo(localDeviceId)
        .and()
        .changeSeqGreaterThan(sinceSeq)
        .count();
  }

  /// Returns the highest [changeSeq] currently in the journal.
  Future<int> getCurrentSeq() async {
    final maxLog =
        await isar.syncChangeLogs.where().sortByChangeSeqDesc().findFirst();
    return maxLog?.changeSeq ?? 0;
  }

  /// Returns the highest change sequence for entries originated locally.
  ///
  /// This is the outbound sync watermark used by pending-change UI and the
  /// push cursor. It is distinct from [getCurrentSeq], which includes remote
  /// replay entries imported from peers.
  Future<int> getCurrentLocalSeq() async {
    final maxLog = await isar.syncChangeLogs
        .filter()
        .originDeviceIdEqualTo(localDeviceId)
        .sortByChangeSeqDesc()
        .findFirst();
    return maxLog?.changeSeq ?? 0;
  }

  /// Returns the lowest [changeSeq] still in the journal (after compaction).
  Future<int> getMinSeq() async {
    final minLog =
        await isar.syncChangeLogs.where().sortByChangeSeq().findFirst();
    return minLog?.changeSeq ?? 0;
  }

  /// Marks a list of local changes as acknowledged by a peer.
  ///
  /// [isarIds] must be the Isar integer primary keys (the [SyncChangeLog.id]
  /// field), NOT the UUID [SyncChangeLog.changeId] strings.
  Future<void> markAcknowledged(List<int> isarIds) async {
    await isar.writeTxn(() async {
      for (final id in isarIds) {
        final log = await isar.syncChangeLogs.get(id);
        if (log != null && !log.acknowledged) {
          log.acknowledged = true;
          await isar.syncChangeLogs.put(log);
        }
      }
    });
  }

  /// Prunes journal entries older than [retentionDays] that have been
  /// acknowledged by all known peers (cursor-safe compaction).
  ///
  /// [minPeerCursor] is the lowest cursor across all active peers.
  /// We only delete entries below that cursor to avoid breaking any peer.
  Future<int> pruneOldEntries({
    required int retentionDays,
    required int minPeerCursor,
  }) async {
    final cutoffMs = DateTime.now()
        .subtract(Duration(days: retentionDays))
        .millisecondsSinceEpoch;

    int deleted = 0;
    await isar.writeTxn(() async {
      final candidates = await isar.syncChangeLogs
          .filter()
          .timestampMsLessThan(cutoffMs)
          .and()
          .acknowledgedEqualTo(true)
          .and()
          .changeSeqLessThan(minPeerCursor + 1)
          .findAll();

      final ids = candidates.map((e) => e.id).toList();
      deleted = ids.length;
      if (ids.isNotEmpty) {
        await isar.syncChangeLogs.deleteAll(ids);
        debugPrint(
            '[ChangeJournal]: pruned $deleted old entries (minPeerCursor=$minPeerCursor)');
      }
    });
    return deleted;
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
