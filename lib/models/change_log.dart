import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'change_log.g.dart';

enum ChangeOperation {
  create,
  update,
  delete,
}

@collection
class ChangeLog {
  ChangeLog();

  ChangeLog.create({
    required this.collection,
    required this.recordId,
    required this.operation,
    required this.timestamp,
    required this.originDeviceId,
    required this.changeSeq,
    String? opId,
    this.synced = false,
  }) : opId = opId ?? const Uuid().v4();

  Id id = Isar.autoIncrement;

  @Index()
  late String collection;

  @Index()
  late String recordId;

  @Index(unique: true, replace: false)
  late String opId;

  @Enumerated(EnumType.name)
  late ChangeOperation operation;

  @Index()
  late int changeSeq;

  @Index()
  late DateTime timestamp;

  @Index()
  bool synced = false;

  late String originDeviceId;

  Map<String, dynamic> toSyncJson(Map<String, dynamic>? payload) {
    return {
      'collection': collection,
      'recordId': recordId,
      'opId': opId,
      'changeSeq': changeSeq,
      'operation': operation.name,
      'timestamp': timestamp.toIso8601String(),
      'originDeviceId': originDeviceId,
      'payload': payload,
    };
  }
}
