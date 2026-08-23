import 'package:isar_community/isar.dart';

part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  @Index()
  late int version;

  @Index()
  late int updatedAt; // Stored as millisecondsSinceEpoch

  @Index()
  late String deviceId;

  @Index()
  late bool isDeleted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'updatedAt': updatedAt,
      'deviceId': deviceId,
      'isDeleted': isDeleted,
    };
  }

  static Item fromJson(Map<String, dynamic> json) {
    return Item()
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..name = json['name'] as String
      ..version = json['version'] as int
      ..updatedAt = json['updatedAt'] as int
      ..deviceId = json['deviceId'] as String
      ..isDeleted = json['isDeleted'] as bool;
  }
}
