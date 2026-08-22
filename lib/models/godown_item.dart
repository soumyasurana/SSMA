import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'godown_item.g.dart';

@collection
class GodownItem {
  // Isar primary key
  Id isarId = Isar.autoIncrement;

  // Global sync ID (UUID)
  @Index(unique: true)
  String uuid = const Uuid().v4();

  late String name;
  int quantity = 0;
  double unitCost = 0.0;
  String? unit; // e.g. "pcs", "kg", "box"
  String? notes;

  /// UUID of the linked inventory Product (if added from inventory)
  @Index()
  String? productUuid;

  // Sync fields
  @Index()
  int version = 1;

  String deviceId = 'unknown';

  @Index()
  bool isSynced = false;

  @Index()
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  GodownItem();

  GodownItem.create({
    required this.name,
    required this.quantity,
    this.unitCost = 0.0,
    this.unit,
    this.notes,
    this.productUuid,
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

  void touch() {
    updatedAt = DateTime.now();
    version++;
    isSynced = false;
  }

  Map<String, dynamic> toJson() => {
        "id": uuid,
        "name": name,
        "quantity": quantity,
        "unit_cost": unitCost,
        "unit": unit,
        "notes": notes,
        "product_uuid": productUuid,
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  static GodownItem fromJson(Map<String, dynamic> json) {
    final item = GodownItem();

    item.uuid = json["id"];
    item.name = json["name"];
    item.quantity = json["quantity"] ?? 0;
    item.unitCost = (json["unit_cost"] ?? 0).toDouble();
    item.unit = json["unit"];
    item.notes = json["notes"];
    item.productUuid = json["product_uuid"] as String?;

    item.version = json["version"] ?? 1;
    item.deviceId = json["device_id"] ?? 'unknown';
    item.deleted = json["is_deleted"] ?? false;

    item.createdAt = DateTime.parse(json["created_at"]);
    item.updatedAt = DateTime.parse(json["updated_at"]);

    item.isSynced = true;

    return item;
  }
}
