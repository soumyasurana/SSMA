import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

part 'product.g.dart';

@collection
class Product {
  // Local Isar primary key
  Id isarId = Isar.autoIncrement;

  // Global sync ID (UUID)
  @Index(unique: true)
  String uuid = const Uuid().v4();

  late String name;

  double salePrice = 0;
  double purchasePrice = 0;

  // Cached stock (authoritative on backend)
  int quantity = 0;

  String? imagePath;

  // -------- Sync fields --------
  @Index()
  int version = 1;

  String deviceId = 'unknown';

  @Index()
  bool isSynced = false;

  @Index()
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Product();

  Product.create({
    required this.name,
    required this.salePrice,
    required this.purchasePrice,
    required this.quantity,
    this.imagePath,
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

  // Call this whenever product is modified locally
  void touch() {
    updatedAt = DateTime.now();
    version++;
    isSynced = false;
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

  static int _sanitizeQuantity(dynamic val) {
    if (val == null) return 0;
    if (val is num) {
      if (!val.toDouble().isFinite || val.toDouble().isNaN) return 0;
      return val.toInt();
    }
    if (val is String) {
      final parsed = int.tryParse(val);
      return parsed ?? 0;
    }
    return 0;
  }

  // ---------------------------
  // JSON → BACKEND
  // ---------------------------
  Map<String, dynamic> toJson() => {
        "id": uuid,
        "name": name,
        "sale_price": _sanitizeMonetary(salePrice),
        "purchase_price": _sanitizeMonetary(purchasePrice),
        "quantity": _sanitizeQuantity(quantity),
        "image_path": imagePath,
        "version": version,
        "device_id": deviceId,
        "is_deleted": deleted,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  // ---------------------------
  // JSON ← BACKEND
  // ---------------------------
  static Product fromJson(Map<String, dynamic> json) {
    final p = Product();

    p.uuid = json["id"];
    p.name = json["name"];

    p.salePrice = _sanitizeMonetary(json["sale_price"]);
    p.purchasePrice = _sanitizeMonetary(json["purchase_price"]);
    p.quantity = _sanitizeQuantity(json["quantity"]);

    p.imagePath = json["image_path"];

    p.version = json["version"] ?? 1;
    p.deviceId = json["device_id"];
    p.deleted = json["is_deleted"] ?? false;

    p.createdAt = DateTime.parse(json["created_at"]);
    p.updatedAt = DateTime.parse(json["updated_at"]);

    p.isSynced = true;

    return p;
  }
}
