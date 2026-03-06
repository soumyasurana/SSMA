import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'sale_item.dart';

part 'sale.g.dart';

enum SaleType { cash, credit }

@collection
class Sale {

  // Isar primary key (required)
  Id isarId = Isar.autoIncrement;

  // Global sync ID
  late String uuid;

  // Foreign key (Customer UUID) – nullable for walk-ins
  String? customerUuid;

  String? buyerName;
  String? buyerContact;

  double totalAmount = 0.0;
  double amountReceived = 0.0;
  late DateTime date;

  @Enumerated(EnumType.name)
  late SaleType saleType;

  late List<SaleItem> items;

  String? comment;

  // Sync fields
  int version = 1;
  late String deviceId;
  bool isSynced = false;
  bool deleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Sale();

  factory Sale.create({
    String? customerUuid,
    String? buyerName,
    String? buyerContact,
    double totalAmount = 0.0,
    double amountReceived = 0.0,
    required DateTime date,
    required SaleType saleType,
    required List<SaleItem> items,
    String? comment,
    required String deviceId,
  }) {
    final now = DateTime.now();

    return Sale()
      ..uuid = const Uuid().v4()
      ..customerUuid = customerUuid
      ..buyerName = buyerName
      ..buyerContact = buyerContact
      ..totalAmount = totalAmount
      ..amountReceived = amountReceived
      ..date = date
      ..saleType = saleType
      ..items = items
      ..comment = comment
      ..deviceId = deviceId
      ..version = 1
      ..isSynced = false
      ..deleted = false
      ..createdAt = now
      ..updatedAt = now;
  }

  // ---------------------------
  // JSON → BACKEND
  // ---------------------------
  Map<String, dynamic> toJson() => {
        "id": uuid,
        "customer_id": customerUuid,
        "buyer_name": buyerName,
        "buyer_contact": buyerContact,
        "total_amount": totalAmount,
        "amount_received": amountReceived,
        "sale_date": date.toIso8601String(),
        "sale_type": saleType.name,
        "comment": comment,
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
  static Sale fromJson(Map<String, dynamic> json) {
    final s = Sale();

    s.uuid = json["id"];
    s.customerUuid = json["customer_id"];

    s.buyerName = json["buyer_name"];
    s.buyerContact = json["buyer_contact"];

    s.totalAmount = (json["total_amount"] ?? 0).toDouble();
    s.amountReceived = (json["amount_received"] ?? 0).toDouble();

    s.date = DateTime.parse(json["sale_date"]);

    s.saleType = SaleType.values.firstWhere(
      (e) => e.name == json["sale_type"],
      orElse: () => SaleType.cash,
    );

    s.comment = json["comment"];

    final itemsJson = json["items"] as List<dynamic>? ?? [];
    s.items = itemsJson.map((e) => SaleItem.fromJson(e)).toList();

    s.version = json["version"];
    s.deviceId = json["device_id"];
    s.deleted = json["is_deleted"] ?? false;

    s.createdAt = DateTime.parse(json["created_at"]);
    s.updatedAt = DateTime.parse(json["updated_at"]);

    s.isSynced = true;

    return s;
  }
}
