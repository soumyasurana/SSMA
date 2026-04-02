import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'item.g.dart';

@collection
class Item {
  Item();

  Item.create({
    required this.name,
    required this.deviceId,
  }) {
    recordId = const Uuid().v4();
    updatedAt = DateTime.now().toUtc();
    version = 1;
    isDeleted = false;
  }

  Id id = Isar.autoIncrement;

  // Stable identifier used across devices and changelogs.
  @Index(unique: true, replace: true)
  late String recordId;

  late String name;

  @Index()
  DateTime updatedAt = DateTime.now().toUtc();

  @Index()
  int version = 0;

  @Index()
  bool isDeleted = false;

  late String deviceId;

  Map<String, dynamic> toSyncJson() {
    return {
      'recordId': recordId,
      'name': name,
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
      'deviceId': deviceId,
    };
  }

  static Item fromSyncJson(Map<String, dynamic> json) {
    return Item()
      ..recordId = json['recordId'] as String
      ..name = json['name'] as String
      ..updatedAt = DateTime.parse(json['updatedAt'] as String).toUtc()
      ..version = (json['version'] as num?)?.toInt() ?? 0
      ..isDeleted = json['isDeleted'] as bool? ?? false
      ..deviceId = json['deviceId'] as String;
  }
}
