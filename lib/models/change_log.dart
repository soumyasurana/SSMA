import 'package:isar_community/isar.dart';

part 'change_log.g.dart';

@collection
class ChangeLog {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String opId; // Globally unique opId

  @Index()
  late int changeSeq; // Monotonically increasing local changeSeq

  @Index()
  late String collection; // E.g., 'Item'

  @Index()
  late int recordId; // Target record ID

  @Index()
  late String operationType; // CREATE, UPDATE, DELETE

  late String payload; // JSON serialized payload

  @Index()
  late int timestamp; // Milliseconds since epoch

  @Index()
  late bool synced; // Has this been fully propagated?

  @Index()
  late String originDeviceId; // Device that generated the change

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opId': opId,
      'changeSeq': changeSeq,
      'collection': collection,
      'recordId': recordId,
      'operationType': operationType,
      'payload': payload,
      'timestamp': timestamp,
      'synced': synced,
      'originDeviceId': originDeviceId,
    };
  }

  static ChangeLog fromJson(Map<String, dynamic> json) {
    return ChangeLog()
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..opId = json['opId'] as String
      ..changeSeq = json['changeSeq'] as int
      ..collection = json['collection'] as String
      ..recordId = json['recordId'] as int
      ..operationType = json['operationType'] as String
      ..payload = json['payload'] as String
      ..timestamp = json['timestamp'] as int
      ..synced = json['synced'] as bool
      ..originDeviceId = json['originDeviceId'] as String;
  }
}
