import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'supplier_payment.g.dart';

@collection
class SupplierPayment {

  // Isar primary key (required)
  Id isarId = Isar.autoIncrement;

  // Global sync ID
  late String uuid;

  // Foreign key (Supplier UUID)
  late String supplierUuid;

  double amount = 0;
  late DateTime date;
  String? note;

  // Sync fields
  int version = 1;
  late String deviceId;
  bool isSynced = false;
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  SupplierPayment();

  SupplierPayment.create({
    required this.supplierUuid,
    required this.amount,
    required this.date,
    this.note,
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
        "supplier_id": supplierUuid,
        "amount": amount,
        "payment_date": date.toIso8601String(),
        "note": note,
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  // ---------------------------
  // JSON ← BACKEND
  // ---------------------------
  static SupplierPayment fromJson(Map<String, dynamic> json) {
    final p = SupplierPayment();

    p.uuid = json["id"];
    p.supplierUuid = json["supplier_id"];

    p.amount = (json["amount"] ?? 0).toDouble();
    p.date = DateTime.parse(json["payment_date"]);
    p.note = json["note"];

    p.version = json["version"];
    p.deviceId = json["device_id"];
    p.deleted = json["is_deleted"] ?? false;

    p.createdAt = DateTime.parse(json["created_at"]);
    p.updatedAt = DateTime.parse(json["updated_at"]);

    p.isSynced = true;

    return p;
  }
}
