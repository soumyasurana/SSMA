import 'package:isar_community/isar.dart';

part 'sync_cursor.g.dart';

/// Per-device synchronization cursor.
///
/// Tracks exactly where each local device is in the remote device's change
/// journal. This is the "last known position" that enables incremental sync.
///
/// Git analogy: this is the remote tracking reference (e.g. origin/main).
/// The cursor advances only after a full round-trip is acknowledged.
@collection
class SyncCursor {
  /// Isar local primary key.
  Id id = Isar.autoIncrement;

  /// The remote device ID this cursor tracks.
  @Index(unique: true, replace: true)
  late String remoteDeviceId;

  /// The last [SyncChangeLog.changeSeq] we have successfully received and
  /// applied from [remoteDeviceId].
  ///
  /// Next pull will request `changeSeq > lastReceivedSeq`.
  /// Initialized to 0 (pull everything from the beginning).
  int lastReceivedSeq = 0;

  /// The last [SyncChangeLog.changeSeq] on the *remote* device that we sent
  /// to them (i.e. the last sequence they acknowledged from us).
  /// Used to avoid re-sending already-delivered changes.
  int lastSentSeq = 0;

  /// Milliseconds since epoch of the last successful pull from this device.
  int lastPullMs = 0;

  /// Milliseconds since epoch of the last successful push to this device.
  int lastPushMs = 0;

  /// Milliseconds since epoch of the last complete sync cycle
  /// (pull + push both succeeded).
  int lastFullSyncMs = 0;

  /// Number of changes received from this device in the last sync.
  int lastPullCount = 0;

  /// Number of changes sent to this device in the last sync.
  int lastPushCount = 0;

  /// Total number of changes ever received from this device.
  int totalReceived = 0;

  /// Total number of changes ever sent to this device.
  int totalSent = 0;

  // -----------------------------------------------------------------------
  // Serialization
  // -----------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'remoteDeviceId': remoteDeviceId,
        'lastReceivedSeq': lastReceivedSeq,
        'lastSentSeq': lastSentSeq,
        'lastPullMs': lastPullMs,
        'lastPushMs': lastPushMs,
        'lastFullSyncMs': lastFullSyncMs,
        'lastPullCount': lastPullCount,
        'lastPushCount': lastPushCount,
        'totalReceived': totalReceived,
        'totalSent': totalSent,
      };
}
