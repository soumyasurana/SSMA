import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../models/sync_cursor.dart';

/// Manages per-device synchronization cursors.
///
/// Each [SyncCursor] tracks our position in a specific remote device's
/// change journal. The cursor only advances after both sides confirm
/// a successful sync round-trip (pull ACK + push ACK).
///
/// Resume guarantee: if sync is interrupted at any point before commit,
/// the cursor is not advanced. The next sync resumes from the same position.
class CursorManager {
  final Isar isar;

  CursorManager({required this.isar});

  // -----------------------------------------------------------------------
  // Read
  // -----------------------------------------------------------------------

  /// Returns the cursor for [remoteDeviceId], creating one at seq=0 if absent.
  Future<SyncCursor> getCursor(String remoteDeviceId) async {
    final existing = await isar.syncCursors
        .filter()
        .remoteDeviceIdEqualTo(remoteDeviceId)
        .findFirst();
    if (existing != null) return existing;

    // First time seeing this device — start from 0 (pull full history)
    final fresh = SyncCursor()
      ..remoteDeviceId = remoteDeviceId
      ..lastReceivedSeq = 0
      ..lastSentSeq = 0;

    await isar.writeTxn(() => isar.syncCursors.put(fresh));
    debugPrint('[CursorManager]: created new cursor for $remoteDeviceId at seq=0');
    return fresh;
  }

  /// Returns the last received sequence for [remoteDeviceId].
  Future<int> getLastReceivedSeq(String remoteDeviceId) async {
    final cursor = await getCursor(remoteDeviceId);
    return cursor.lastReceivedSeq;
  }

  // -----------------------------------------------------------------------
  // Advance (only called after successful acknowledgement)
  // -----------------------------------------------------------------------

  /// Advances the receive cursor after a successful pull + apply cycle.
  ///
  /// Call this ONLY after all received changes have been written to the DB
  /// and the peer has been notified. Calling it earlier would break resume.
  Future<void> advanceReceiveCursor({
    required String remoteDeviceId,
    required int newSeq,
    required int changeCount,
  }) async {
    await isar.writeTxn(() async {
      final cursor = await isar.syncCursors
          .filter()
          .remoteDeviceIdEqualTo(remoteDeviceId)
          .findFirst() ??
          (SyncCursor()..remoteDeviceId = remoteDeviceId);

      cursor.lastReceivedSeq = newSeq;
      cursor.lastPullMs = DateTime.now().millisecondsSinceEpoch;
      cursor.lastPullCount = changeCount;
      cursor.totalReceived += changeCount;

      await isar.syncCursors.put(cursor);
    });

    debugPrint('[CursorManager]: ↓ advanced recv cursor for $remoteDeviceId to seq=$newSeq (+$changeCount changes)');
  }

  /// Advances the send cursor after the peer confirms receipt.
  Future<void> advanceSendCursor({
    required String remoteDeviceId,
    required int newSeq,
    required int changeCount,
  }) async {
    await isar.writeTxn(() async {
      final cursor = await isar.syncCursors
          .filter()
          .remoteDeviceIdEqualTo(remoteDeviceId)
          .findFirst() ??
          (SyncCursor()..remoteDeviceId = remoteDeviceId);

      cursor.lastSentSeq = newSeq;
      cursor.lastPushMs = DateTime.now().millisecondsSinceEpoch;
      cursor.lastPushCount = changeCount;
      cursor.totalSent += changeCount;

      await isar.syncCursors.put(cursor);
    });

    debugPrint('[CursorManager]: ↑ advanced send cursor for $remoteDeviceId to seq=$newSeq (+$changeCount changes)');
  }

  /// Records a completed full sync round-trip.
  Future<void> recordFullSync(String remoteDeviceId) async {
    await isar.writeTxn(() async {
      final cursor = await isar.syncCursors
          .filter()
          .remoteDeviceIdEqualTo(remoteDeviceId)
          .findFirst();
      if (cursor != null) {
        cursor.lastFullSyncMs = DateTime.now().millisecondsSinceEpoch;
        await isar.syncCursors.put(cursor);
      }
    });
  }

  // -----------------------------------------------------------------------
  // Reset
  // -----------------------------------------------------------------------

  /// Resets the cursor for [remoteDeviceId] to 0 (force full re-sync).
  ///
  /// Use this only for explicit user action ("Force Full Sync").
  Future<void> resetCursor(String remoteDeviceId) async {
    await isar.writeTxn(() async {
      final cursor = await isar.syncCursors
          .filter()
          .remoteDeviceIdEqualTo(remoteDeviceId)
          .findFirst();
      if (cursor != null) {
        cursor.lastReceivedSeq = 0;
        cursor.lastSentSeq = 0;
        cursor.lastPullMs = 0;
        cursor.lastPushMs = 0;
        cursor.lastFullSyncMs = 0;
        await isar.syncCursors.put(cursor);
        debugPrint('[CursorManager]: ⚠ cursor RESET for $remoteDeviceId');
      }
    });
  }

  /// Deletes the cursor for a removed device.
  Future<void> deleteCursor(String remoteDeviceId) async {
    await isar.writeTxn(() async {
      final cursor = await isar.syncCursors
          .filter()
          .remoteDeviceIdEqualTo(remoteDeviceId)
          .findFirst();
      if (cursor != null) {
        await isar.syncCursors.delete(cursor.id);
      }
    });
  }

  /// Returns the lowest cursor value across all active peers.
  /// Used by the compactor to know the safe pruning boundary.
  Future<int> getMinPeerCursor() async {
    final cursors = await isar.syncCursors.where().findAll();
    if (cursors.isEmpty) return 0;
    return cursors.map((c) => c.lastReceivedSeq).reduce((a, b) => a < b ? a : b);
  }

  /// Returns all cursors (for diagnostic display).
  Future<List<SyncCursor>> getAllCursors() {
    return isar.syncCursors.where().findAll();
  }
}
