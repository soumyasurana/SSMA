import 'package:isar/isar.dart';

part 'peer_device.g.dart';

/// Represents a discovered or paired device on the local network.
///
/// Every device in the ecosystem is stored here once discovered.
/// The [pairedAt] field is non-null only for trusted (paired) devices.
/// Untrusted devices are visible for pairing but cannot sync data.
@collection
class PeerDevice {
  /// Isar local primary key.
  Id id = Isar.autoIncrement;

  /// Permanent, globally unique device ID (UUID v4, never changes).
  @Index(unique: true, replace: true)
  late String deviceId;

  /// Human-readable device name (e.g. "Soumya's Phone").
  late String deviceName;

  /// Platform string ('android', 'ios', 'windows', 'macos', 'linux').
  late String platform;

  /// Application version string (e.g. '1.0.0').
  late String appVersion;

  /// Last known LAN IPv4 address.
  late String lastKnownIp;

  /// Last known port of this device's sync server.
  int lastKnownPort = 8080;

  /// Milliseconds since epoch when this device was last seen alive.
  @Index()
  late int lastSeenMs;

  /// Milliseconds since epoch of last successful sync with this device.
  /// 0 means we have never completed a full sync cycle with this device.
  int lastSyncMs = 0;

  /// Health / reachability status.
  /// Values: 'unknown', 'reachable', 'unreachable', 'syncing'.
  @Index()
  String connectionStatus = 'unknown';

  /// Whether this device is trusted (paired).
  /// Only paired devices may push/pull change data.
  @Index()
  bool isPaired = false;

  /// Milliseconds since epoch when pairing was accepted, null if not paired.
  int? pairedAtMs;

  /// Whether we accept incoming changes from this device.
  bool receiveEnabled = true;

  /// Whether we send our local changes to this device.
  bool sendEnabled = true;

  /// Whether automatic sync with this device is active.
  bool autoSyncEnabled = true;

  /// Milliseconds since epoch when this device was first registered locally.
  late int registeredAtMs;

  /// OS version string, if reported.
  String? osVersion;

  // -----------------------------------------------------------------------
  // Serialization
  // -----------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': platform,
        'appVersion': appVersion,
        'lastKnownIp': lastKnownIp,
        'lastKnownPort': lastKnownPort,
        'lastSeenMs': lastSeenMs,
        'lastSyncMs': lastSyncMs,
        'connectionStatus': connectionStatus,
        'isPaired': isPaired,
        'pairedAtMs': pairedAtMs,
        'receiveEnabled': receiveEnabled,
        'sendEnabled': sendEnabled,
        'autoSyncEnabled': autoSyncEnabled,
        'registeredAtMs': registeredAtMs,
        'osVersion': osVersion,
      };

  static PeerDevice fromJson(Map<String, dynamic> json) {
    return PeerDevice()
      ..deviceId = json['deviceId'] as String
      ..deviceName = json['deviceName'] as String? ?? 'Unknown Device'
      ..platform = json['platform'] as String? ?? 'unknown'
      ..appVersion = json['appVersion'] as String? ?? '0.0.0'
      ..lastKnownIp = json['lastKnownIp'] as String? ?? ''
      ..lastKnownPort = json['lastKnownPort'] as int? ?? 8080
      ..lastSeenMs = json['lastSeenMs'] as int? ?? DateTime.now().millisecondsSinceEpoch
      ..lastSyncMs = json['lastSyncMs'] as int? ?? 0
      ..connectionStatus = json['connectionStatus'] as String? ?? 'unknown'
      ..isPaired = json['isPaired'] as bool? ?? false
      ..pairedAtMs = json['pairedAtMs'] as int?
      ..receiveEnabled = json['receiveEnabled'] as bool? ?? true
      ..sendEnabled = json['sendEnabled'] as bool? ?? true
      ..autoSyncEnabled = json['autoSyncEnabled'] as bool? ?? true
      ..registeredAtMs = json['registeredAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch
      ..osVersion = json['osVersion'] as String?;
  }
}
