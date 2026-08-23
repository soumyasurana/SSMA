import 'package:isar_community/isar.dart';
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

  static double _sanitizeMonetary(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) {
      final d = val.toDouble();
      if (!d.isFinite || d.isNaN) return 0.0;
      return d < 0 ? 0.0 : d;
    }
    if (val is String) {
      final parsed = double.tryParse(val);
      if (parsed == null || !parsed.isFinite || parsed.isNaN) return 0.0;
      return parsed < 0 ? 0.0 : parsed;
    }
    return 0.0;
  }

  // ---------------------------
  // JSON → BACKEND
  // ---------------------------
  Map<String, dynamic> toJson() => {
        "id": uuid,
        "supplier_id": supplierUuid,
        "total_amount": _sanitizeMonetary(totalAmount),
        "amount_paid": _sanitizeMonetary(amountPaid),
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

    p.totalAmount = _sanitizeMonetary(json["total_amount"]);
    p.amountPaid = _sanitizeMonetary(json["amount_paid"]);
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
