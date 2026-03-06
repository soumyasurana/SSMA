import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'supplier.g.dart';

@collection
class Supplier {

  // Isar primary key (required)
  Id isarId = Isar.autoIncrement;

  // Global sync ID
  late String uuid;

  late String name;
  late String contact;
  String? address;

  // Sync fields
  int version = 1;
  late String deviceId;
  bool isSynced = false;
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Supplier();

  Supplier.create({
    required this.name,
    required this.contact,
    this.address,
    required this.deviceId,
  }) {
    final now = DateTime.now();

    uuid = const Uuid().v4();
    createdAt = now;
    updatedAt = now;

    version = 1;
    isSynced = false;
    deleted = false;
  }

  // ---------------------------
  // JSON → BACKEND
  // ---------------------------
  Map<String, dynamic> toJson() => {
        "id": uuid,
        "name": name,
        "contact": contact,
        "address": address,
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  // ---------------------------
  // JSON ← BACKEND
  // ---------------------------
  static Supplier fromJson(Map<String, dynamic> json) {
    final s = Supplier();

    s.uuid = json["id"];
    s.name = json["name"];
    s.contact = json["contact"];
    s.address = json["address"];

    s.version = json["version"];
    s.deviceId = json["device_id"];
    s.deleted = json["is_deleted"] ?? false;

    s.createdAt = DateTime.parse(json["created_at"]);
    s.updatedAt = DateTime.parse(json["updated_at"]);

    s.isSynced = true;

    return s;
  }
}
