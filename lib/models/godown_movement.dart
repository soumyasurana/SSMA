import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

part 'godown_movement.g.dart';

enum GodownMovementType {
  stockAdded,
  quantityIncreased,
  quantityDecreased,
  transferToShop,
  manualAdjustment,
  stockRemoved,
}

@collection
class GodownMovement {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = const Uuid().v4();

  @Index()
  late String godownItemUuid;

  late String godownItemName;

  @Enumerated(EnumType.name)
  late GodownMovementType movementType;

  int quantityChanged = 0; // Positive for additions, negative for reductions
  int remainingQuantity = 0;

  String? referenceId; // e.g. target product UUID for transfers
  String? note;

  DateTime createdAt = DateTime.now();

  GodownMovement();

  GodownMovement.create({
    required this.godownItemUuid,
    required this.godownItemName,
    required this.movementType,
    required this.quantityChanged,
    required this.remainingQuantity,
    this.referenceId,
    this.note,
  }) {
    uuid = const Uuid().v4();
    createdAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        "id": uuid,
        "godown_item_id": godownItemUuid,
        "godown_item_name": godownItemName,
        "movement_type": movementType.name,
        "quantity_changed": quantityChanged,
        "remaining_quantity": remainingQuantity,
        "reference_id": referenceId,
        "note": note,
        "created_at": createdAt.toIso8601String(),
      };

  static GodownMovement fromJson(Map<String, dynamic> json) {
    final m = GodownMovement();
    m.uuid = json["id"];
    m.godownItemUuid = json["godown_item_id"];
    m.godownItemName = json["godown_item_name"];
    m.movementType = GodownMovementType.values.firstWhere(
      (e) => e.name == json["movement_type"],
      orElse: () => GodownMovementType.manualAdjustment,
    );
    m.quantityChanged = json["quantity_changed"] ?? 0;
    m.remainingQuantity = json["remaining_quantity"] ?? 0;
    m.referenceId = json["reference_id"];
    m.note = json["note"];
    m.createdAt = DateTime.parse(json["created_at"]);
    return m;
  }
}
