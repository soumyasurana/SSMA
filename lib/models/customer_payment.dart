import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

part 'customer_payment.g.dart';

@collection
class CustomerPayment {
  // Isar primary key (local)
  Id isarId = Isar.autoIncrement;

  // Global sync ID (UUID)
  late String uuid;

  // Foreign key (Customer UUID)
  late String customerUuid;

  late String customerName;

  double amountReceived = 0;
  double previousDue = 0;
  double newDue = 0;

  late DateTime date;

  // Sync fields
  int version = 1;
  late String deviceId;
  bool isSynced = false;
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  CustomerPayment();

  CustomerPayment.create({
    required this.customerUuid,
    required this.customerName,
    required this.amountReceived,
    required this.previousDue,
    required this.newDue,
    required this.date,
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
        "customer_id": customerUuid,
        "customer_name": customerName,
        "amount_received": _sanitizeMonetary(amountReceived),
        "previous_due": _sanitizeMonetary(previousDue),
        "new_due": _sanitizeMonetary(newDue),
        "payment_date": date.toIso8601String(),
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  // ---------------------------
  // JSON ← BACKEND
  // ---------------------------
  static CustomerPayment fromJson(Map<String, dynamic> json) {
    final p = CustomerPayment();

    p.uuid = json["id"];
    p.customerUuid = json["customer_id"];
    p.customerName = json["customer_name"];

    p.amountReceived = _sanitizeMonetary(json["amount_received"]);
    p.previousDue = _sanitizeMonetary(json["previous_due"]);
    p.newDue = _sanitizeMonetary(json["new_due"]);

    p.date = DateTime.parse(json["payment_date"]);

    p.version = json["version"];
    p.deviceId = json["device_id"];
    p.deleted = json["is_deleted"] ?? false;

    p.createdAt = DateTime.parse(json["created_at"]);
    p.updatedAt = DateTime.parse(json["updated_at"]);

    p.isSynced = true;

    return p;
  }
}
