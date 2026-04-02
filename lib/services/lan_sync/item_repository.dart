import 'package:isar/isar.dart';
import 'package:ssma/models/change_log.dart';
import 'package:ssma/models/item.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/lan_sync/change_tracker_service.dart';

class ItemRepository {
  ItemRepository({
    required this.deviceId,
    ChangeTrackerService? changeTracker,
  }) : _changeTracker = changeTracker ?? ChangeTrackerService();

  final String deviceId;
  final ChangeTrackerService _changeTracker;

  Future<List<Item>> getAllActive() async {
    final items = await DBService.isar.items.where().findAll();
    return items.where((item) => !item.isDeleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Item> createItem(String name) async {
    final item = Item.create(
      name: name,
      deviceId: deviceId,
    );
    final changeSeq = await _changeTracker.nextChangeSeq();

    await DBService.isar.writeTxn(() async {
      await DBService.isar.items.putByRecordId(item);
      await DBService.isar.changeLogs.put(
        ChangeLog.create(
          collection: 'items',
          recordId: item.recordId,
          operation: ChangeOperation.create,
          changeSeq: changeSeq,
          timestamp: item.updatedAt,
          originDeviceId: deviceId,
        ),
      );
    });

    return item;
  }

  Future<void> updateItem(Item item, {required String name}) async {
    item
      ..name = name
      ..updatedAt = DateTime.now().toUtc()
      ..version += 1
      ..deviceId = deviceId
      ..isDeleted = false;
    final changeSeq = await _changeTracker.nextChangeSeq();

    await DBService.isar.writeTxn(() async {
      await DBService.isar.items.putByRecordId(item);
      await DBService.isar.changeLogs.put(
        ChangeLog.create(
          collection: 'items',
          recordId: item.recordId,
          operation: ChangeOperation.update,
          changeSeq: changeSeq,
          timestamp: item.updatedAt,
          originDeviceId: deviceId,
        ),
      );
    });
  }

  Future<void> softDeleteItem(Item item) async {
    item
      ..isDeleted = true
      ..updatedAt = DateTime.now().toUtc()
      ..version += 1
      ..deviceId = deviceId;
    final changeSeq = await _changeTracker.nextChangeSeq();

    await DBService.isar.writeTxn(() async {
      await DBService.isar.items.putByRecordId(item);
      await DBService.isar.changeLogs.put(
        ChangeLog.create(
          collection: 'items',
          recordId: item.recordId,
          operation: ChangeOperation.delete,
          changeSeq: changeSeq,
          timestamp: item.updatedAt,
          originDeviceId: deviceId,
        ),
      );
    });
  }
}
