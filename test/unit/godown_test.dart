import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:ssma/models/godown_item.dart';
import 'package:ssma/models/godown_movement.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/sync/v2/services/change_processor.dart';
import 'package:ssma/sync/v2/services/conflict_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory testDir;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('ssma_godown_unit_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return testDir.path;
      }
      return null;
    });

    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    try {
      await DBService.isar.close();
    } catch (_) {}
    if (await testDir.exists()) {
      await for (final entry in testDir.list()) {
        await entry.delete(recursive: true);
      }
    }
    final isar = await DBService.getIsarInitialized();
    EntityRegistry.registerAll(isar: isar);
  });

  tearDownAll(() async {
    try {
      await DBService.isar.close();
    } catch (_) {}
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  group('Godown Stock & Transfer Unit Tests', () {
    test('Godown starts empty', () async {
      final items = await DBService.getGodownItems();
      expect(items, isEmpty);
    });

    test('Add godown item and record movement history', () async {
      final item = GodownItem.create(
        name: 'Open Biscuit 6no.',
        quantity: 500,
        unitCost: 15.0,
        unit: 'box',
        deviceId: 'test-device',
      );

      await DBService.addGodownItem(item);

      final items = await DBService.getGodownItems();
      expect(items.length, 1);
      expect(items.first.name, 'Open Biscuit 6no.');
      expect(items.first.quantity, 500);

      final movements = await DBService.getGodownMovements(items.first.uuid);
      expect(movements.length, 1);
      expect(movements.first.movementType, GodownMovementType.stockAdded);
      expect(movements.first.quantityChanged, 500);
    });

    test('Adjust quantity increases and decreases stock correctly', () async {
      final item = GodownItem.create(
        name: 'Refined Oil',
        quantity: 100,
        deviceId: 'test-device',
      );
      await DBService.addGodownItem(item);

      // Increase
      await DBService.adjustGodownQuantity(
        godownItemUuid: item.uuid,
        deltaQuantity: 50,
      );

      var updated = await DBService.getGodownItemByUuid(item.uuid);
      expect(updated!.quantity, 150);

      // Decrease
      await DBService.adjustGodownQuantity(
        godownItemUuid: item.uuid,
        deltaQuantity: -30,
      );

      updated = await DBService.getGodownItemByUuid(item.uuid);
      expect(updated!.quantity, 120);

      final movements = await DBService.getGodownMovements(item.uuid);
      expect(movements.length, 3); // added, increased, decreased
    });

    test('Transfer to shop reduces godown and increases shop product stock', () async {
      final item = GodownItem.create(
        name: 'Tea Pack 250g',
        quantity: 500,
        unitCost: 80.0,
        deviceId: 'test-device',
      );
      await DBService.addGodownItem(item);

      // Transfer 200 units to shop
      await DBService.transferGodownToShop(
        godownItemUuid: item.uuid,
        transferQuantity: 200,
      );

      final updatedGodown = await DBService.getGodownItemByUuid(item.uuid);
      expect(updatedGodown!.quantity, 300);

      final products = await DBService.getProducts();
      expect(products.length, 1);
      expect(products.first.name, 'Tea Pack 250g');
      expect(products.first.quantity, 200);

      // Transfer another 100 units
      await DBService.transferGodownToShop(
        godownItemUuid: item.uuid,
        transferQuantity: 100,
      );

      final finalGodown = await DBService.getGodownItemByUuid(item.uuid);
      expect(finalGodown!.quantity, 200);

      final updatedProducts = await DBService.getProducts();
      expect(updatedProducts.length, 1);
      expect(updatedProducts.first.quantity, 300);
    });

    test('Transfer requested more than available throws error and stays atomic', () async {
      final item = GodownItem.create(
        name: 'Sugar 50kg',
        quantity: 10,
        deviceId: 'test-device',
      );
      await DBService.addGodownItem(item);

      expect(
        () async => await DBService.transferGodownToShop(
          godownItemUuid: item.uuid,
          transferQuantity: 15,
        ),
        throwsA(isA<StateError>()),
      );

      final godownCheck = await DBService.getGodownItemByUuid(item.uuid);
      expect(godownCheck!.quantity, 10);

      final shopProducts = await DBService.getProducts();
      expect(shopProducts, isEmpty);
    });

    test('GodownItem and GodownMovement are registered in EntityRegistry and applied via ChangeProcessor', () async {
      final isar = DBService.isar;
      final item = GodownItem.create(
        name: 'Remote Sync Oil',
        quantity: 50,
        unitCost: 120.0,
        deviceId: 'peer-device-1',
      );

      final handler = EntityRegistry.get('GodownItem');
      expect(handler, isNotNull);

      // Apply incoming GodownItem CREATE
      await isar.writeTxn(() async {
        await handler!.applyChange(
          item.toJson(),
          'CREATE',
          ConflictResolver(),
          isar,
        );
      });

      final stored = await DBService.getGodownItemByUuid(item.uuid);
      expect(stored, isNotNull);
      expect(stored!.name, 'Remote Sync Oil');
      expect(stored.quantity, 50);

      // Apply incoming GodownMovement CREATE
      final movement = GodownMovement.create(
        godownItemUuid: item.uuid,
        godownItemName: item.name,
        movementType: GodownMovementType.stockAdded,
        quantityChanged: 50,
        remainingQuantity: 50,
      );

      final movementHandler = EntityRegistry.get('GodownMovement');
      expect(movementHandler, isNotNull);

      await isar.writeTxn(() async {
        await movementHandler!.applyChange(
          movement.toJson(),
          'CREATE',
          ConflictResolver(),
          isar,
        );
      });

      final movements = await DBService.getGodownMovements(item.uuid);
      expect(movements.length, 1);
      expect(movements.first.quantityChanged, 50);
    });
  });
}
