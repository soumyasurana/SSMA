import 'package:isar/isar.dart';

part 'pairing_request.g.dart';

/// Represents an in-flight or historical pairing request.
///
/// When Device A discovers Device B for the first time, it may send
/// a pairing request. Device B stores this as 'pending'. The user on
/// Device B accepts or rejects it. The result is stored here.
@collection
class PairingRequest {
  Id id = Isar.autoIncrement;

  /// Unique ID for this pairing request.
  @Index(unique: true, replace: true)
  late String requestId;

  /// Device ID of the device that initiated the pairing.
  @Index()
  late String initiatorDeviceId;

  /// Human-readable name of the initiator at time of request.
  late String initiatorDeviceName;

  /// Platform of the initiator.
  late String initiatorPlatform;

  /// IP address of the initiator at time of request.
  late String initiatorIp;

  /// Local sync server port of the initiator at time of request — needed so
  /// the receiving device can call back with a pair/response once the user
  /// accepts or rejects.
  int? initiatorPort;

  /// Status: 'pending', 'accepted', 'rejected', 'expired'.
  @Index()
  String status = 'pending';

  /// Milliseconds since epoch when this request was received.
  late int receivedAtMs;

  /// Milliseconds since epoch when this request was responded to, if any.
  int? respondedAtMs;

  /// Whether we are the initiator (true) or the receiver (false).
  bool isInitiator = false;

  /// Device ID of the device this request is directed at, if known.
  String? targetDeviceId;

  /// Human-readable name of the target device, if known.
  String? targetDeviceName;

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'initiatorDeviceId': initiatorDeviceId,
        'initiatorDeviceName': initiatorDeviceName,
        'initiatorPlatform': initiatorPlatform,
        'initiatorIp': initiatorIp,
        'initiatorPort': initiatorPort,
        'status': status,
        'receivedAtMs': receivedAtMs,
        'respondedAtMs': respondedAtMs,
        'isInitiator': isInitiator,
        'targetDeviceId': targetDeviceId,
        'targetDeviceName': targetDeviceName,
      };
}