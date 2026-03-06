import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'sale_item.g.dart';

@embedded
class SaleItem {
  late String uuid;

  late String productUuid;
  late String productName;

  int quantity = 0;
  double unitPrice = 0;
  double purchasePrice = 0;
  double total = 0;

  int version = 1;
  late String deviceId;

  bool isSynced = false;
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  SaleItem();

  SaleItem.create({
    required this.productUuid,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchasePrice,
    required this.deviceId,
  }) {
    final now = DateTime.now();

    uuid = const Uuid().v4();
    total = quantity * unitPrice;

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
        "product_id": productUuid,
        "product_name": productName,
        "quantity": quantity,
        "unit_price": unitPrice,
        "purchase_price": purchasePrice,
        "total": total,
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  static SaleItem fromJson(Map<String, dynamic> json) {
    final i = SaleItem();

    i.uuid = json["id"];
    i.productUuid = json["product_id"];
    i.productName = json["product_name"];

    i.quantity = json["quantity"] ?? 0;
    i.unitPrice = (json["unit_price"] ?? 0).toDouble();
    i.purchasePrice = (json["purchase_price"] ?? 0).toDouble();
    i.total = (json["total"] ?? 0).toDouble();

    i.version = json["version"] ?? 1;
    i.deviceId = json["device_id"];
    i.deleted = json["is_deleted"] ?? false;

    i.createdAt = DateTime.parse(json["created_at"]);
    i.updatedAt = DateTime.parse(json["updated_at"]);

    i.isSynced = true;

    return i;
  }
}
