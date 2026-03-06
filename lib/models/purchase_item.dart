import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'purchase_item.g.dart';

@embedded
class PurchaseItem {

  // Global sync ID (NOT Isar primary key)
  late String uuid;

  // Foreign key (Product UUID)
  late String productUuid;

  late String productName;

  double purchasePrice = 0.0;
  int quantity = 0;
  double total = 0.0;

  // Sync fields
  int version = 1;
  late String deviceId;
  bool isSynced = false;
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  PurchaseItem();

  PurchaseItem.create({
    required this.productUuid,
    required this.productName,
    required this.purchasePrice,
    required this.quantity,
    required this.deviceId,
  }) {
    final now = DateTime.now();

    uuid = const Uuid().v4();
    total = quantity * purchasePrice;

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
        "product_id": productUuid,
        "product_name": productName,
        "purchase_price": purchasePrice,
        "quantity": quantity,
        "total": total,
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  // ---------------------------
  // JSON ← BACKEND
  // ---------------------------
  static PurchaseItem fromJson(Map<String, dynamic> json) {
    final i = PurchaseItem();

    i.uuid = json["id"];
    i.productUuid = json["product_id"];
    i.productName = json["product_name"];

    i.purchasePrice = (json["purchase_price"] ?? 0).toDouble();
    i.quantity = json["quantity"] ?? 0;
    i.total = (json["total"] ?? 0).toDouble();

    i.version = json["version"];
    i.deviceId = json["device_id"];
    i.deleted = json["is_deleted"] ?? false;

    i.createdAt = DateTime.parse(json["created_at"]);
    i.updatedAt = DateTime.parse(json["updated_at"]);

    i.isSynced = true;

    return i;
  }
}
