class SyncPeer {
  const SyncPeer({
    required this.instanceName,
    required this.host,
    required this.port,
    required this.address,
    this.deviceId,
    this.lastSeen,
  });

  final String instanceName;
  final String host;
  final int port;
  final String address;
  final String? deviceId;
  final DateTime? lastSeen;

  String get baseUrl => 'http://$address:$port';

  SyncPeer copyWith({
    String? deviceId,
    DateTime? lastSeen,
  }) {
    return SyncPeer(
      instanceName: instanceName,
      host: host,
      port: port,
      address: address,
      deviceId: deviceId ?? this.deviceId,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class SyncChange {
  const SyncChange({
    required this.collection,
    required this.recordId,
    required this.opId,
    required this.changeSeq,
    required this.operation,
    required this.timestamp,
    required this.originDeviceId,
    required this.payload,
  });

  final String collection;
  final String recordId;
  final String opId;
  final int changeSeq;
  final String operation;
  final DateTime timestamp;
  final String originDeviceId;
  final Map<String, dynamic>? payload;

  Map<String, dynamic> toJson() {
    return {
      'collection': collection,
      'recordId': recordId,
      'opId': opId,
      'changeSeq': changeSeq,
      'operation': operation,
      'timestamp': timestamp.toIso8601String(),
      'originDeviceId': originDeviceId,
      'payload': payload,
    };
  }

  static SyncChange fromJson(Map<String, dynamic> json) {
    return SyncChange(
      collection: json['collection'] as String,
      recordId: json['recordId'] as String,
      opId: json['opId'] as String,
      changeSeq: (json['changeSeq'] as num).toInt(),
      operation: json['operation'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      originDeviceId: json['originDeviceId'] as String,
      payload: json['payload'] == null
          ? null
          : Map<String, dynamic>.from(json['payload'] as Map),
    );
  }
}
