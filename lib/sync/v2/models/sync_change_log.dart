import 'package:isar/isar.dart';

part 'sync_change_log.g.dart';

/// The append-only change journal.
///
/// Every create, update, or delete on a synchronized entity writes one
/// record here. Records are immutable once written. The [changeSeq] is the
/// synchronization cursor — it increases monotonically and is never reused.
///
/// Git analogy: each [SyncChangeLog] is a commit in the history. A device
/// that was offline replays every commit after its last-seen sequence.
@collection
class SyncChangeLog {
  /// Isar local primary key (auto-assigned, device-local only).
  Id id = Isar.autoIncrement;

  /// Globally unique operation ID (UUID v4).
  /// Used for idempotency — if the same change arrives twice it is ignored.
  @Index(unique: true, replace: false)
  late String changeId;

  /// Monotonically increasing sequence number, device-local.
  /// Never reused. Used as the synchronization cursor.
  @Index()
  late int changeSeq;

  /// The entity type string, e.g. 'Product', 'Sale', 'Customer'.
  /// Must match the [EntitySyncHandler.entityType] registered in [EntityRegistry].
  @Index()
  late String entityType;

  /// The UUID of the affected entity (business ID, not Isar local ID).
  @Index()
  late String entityId;

  /// The operation: 'CREATE', 'UPDATE', or 'DELETE'.
  late String operation;

  /// Monotonically increasing version of the entity at the time of this change.
  late int entityVersion;

  /// ID of the device that originated this change.
  @Index()
  late String originDeviceId;

  /// Wall-clock time of this change (ms since epoch).
  /// Used only as a tie-breaker; ordering is determined by [changeSeq].
  late int timestampMs;

  /// Full JSON serialization of the entity at the time of this change.
  /// For DELETE operations this carries the final tombstone state.
  late String payload;

  /// Optional SHA-256 hash of the previous change for this entity.
  /// Enables chain-of-custody verification in high-security deployments.
  String? previousChangeHash;

  /// Whether this change has been acknowledged by at least one peer.
  /// Used by the compactor to know when it is safe to prune old entries.
  @Index()
  bool acknowledged = false;

  // -----------------------------------------------------------------------
  // Serialization
  // -----------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'changeId': changeId,
        'changeSeq': changeSeq,
        'entityType': entityType,
        'entityId': entityId,
        'operation': operation,
        'entityVersion': entityVersion,
        'originDeviceId': originDeviceId,
        'timestampMs': timestampMs,
        'payload': payload,
        'previousChangeHash': previousChangeHash,
      };

  static SyncChangeLog fromJson(Map<String, dynamic> json) {
    return SyncChangeLog()
      ..changeId = json['changeId'] as String
      ..changeSeq = json['changeSeq'] as int
      ..entityType = json['entityType'] as String
      ..entityId = json['entityId'] as String
      ..operation = json['operation'] as String
      ..entityVersion = json['entityVersion'] as int
      ..originDeviceId = json['originDeviceId'] as String
      ..timestampMs = json['timestampMs'] as int
      ..payload = json['payload'] as String
      ..previousChangeHash = json['previousChangeHash'] as String?
      ..acknowledged = false;
  }
}
