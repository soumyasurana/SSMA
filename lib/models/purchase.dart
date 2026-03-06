import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'purchase_item.dart';

part 'purchase.g.dart';

@collection
class Purchase {

  // Isar primary key (required)
  Id isarId = Isar.autoIncrement;

  // Global sync ID
  late String uuid;

  // Foreign key (Supplier UUID)
  late String supplierUuid;

  late List<PurchaseItem> items;

  double totalAmount = 0;
  late DateTime date;

  double amountPaid = 0;
  String? note;

  int version = 1;
  late String deviceId;
  bool isSynced = false;
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Purchase();

  Purchase.create({
    required this.supplierUuid,
    required List<PurchaseItem> purchaseItems,
    required this.totalAmount,
    required this.date,
    required this.deviceId,
    this.amountPaid = 0,
    this.note,
  }) {
    final now = DateTime.now();

    uuid = const Uuid().v4();
    items = purchaseItems;

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
        "supplier_id": supplierUuid,
        "total_amount": totalAmount,
        "amount_paid": amountPaid,
        "purchase_date": date.toIso8601String(),
        "note": note,
        "items": items.map((e) => e.toJson()).toList(),
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  // ---------------------------
  // JSON ← BACKEND
  // ---------------------------
  static Purchase fromJson(Map<String, dynamic> json) {
    final p = Purchase();

    p.uuid = json["id"];
    p.supplierUuid = json["supplier_id"];

    p.totalAmount = (json["total_amount"] ?? 0).toDouble();
    p.amountPaid = (json["amount_paid"] ?? 0).toDouble();
    p.date = DateTime.parse(json["purchase_date"]);

    p.note = json["note"];

    final itemsJson = json["items"] as List<dynamic>? ?? [];
    p.items = itemsJson.map((e) => PurchaseItem.fromJson(e)).toList();

    p.version = json["version"];
    p.deviceId = json["device_id"];
    p.deleted = json["is_deleted"] ?? false;

    p.createdAt = DateTime.parse(json["created_at"]);
    p.updatedAt = DateTime.parse(json["updated_at"]);

    p.isSynced = true;

    return p;
  }
}
