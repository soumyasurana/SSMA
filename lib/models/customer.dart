import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

part 'customer.g.dart';

@collection
class Customer {
  // Isar primary key (local only)
  Id isarId = Isar.autoIncrement;

  // Global sync ID (UUID)
  String uuid = const Uuid().v4();

  late String name;
  String? phone;
  double pendingDues = 0;
  double advanceBalance = 0;

  // Sync fields
  int version = 1;
  String deviceId = 'unknown';
  bool isSynced = false;
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Customer();

  Customer.create({
    required this.name,
    this.phone,
    this.pendingDues = 0,
    this.advanceBalance = 0,
    required this.deviceId,
  }) {
    final now = DateTime.now();

    uuid = const Uuid().v4(); // ✅ FIXED
    createdAt = now;
    updatedAt = now;

    deleted = false;
    isSynced = false;
    version = 1;
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
        "id": uuid, // ✅ backend ID = uuid
        "name": name,
        "phone": phone,
        "pending_dues": _sanitizeMonetary(pendingDues),
        "advance_balance": _sanitizeMonetary(advanceBalance),
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  // ---------------------------
  // JSON ← BACKEND
  // ---------------------------
  static Customer fromJson(Map<String, dynamic> json) {
    final c = Customer();

    c.uuid = json["id"]; // ✅ FIXED
    c.name = json["name"];
    c.phone = json["phone"];
    c.pendingDues = _sanitizeMonetary(json["pending_dues"]);
    c.advanceBalance = _sanitizeMonetary(json["advance_balance"]);

    c.version = json["version"];
    c.deviceId = json["device_id"];
    c.deleted = json["is_deleted"] ?? false;

    c.createdAt = DateTime.parse(json["created_at"]);
    c.updatedAt = DateTime.parse(json["updated_at"]);

    c.isSynced = true;

    return c;
  }
}
