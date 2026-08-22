import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:ssma/models/godown_item.dart';
import 'package:ssma/models/godown_movement.dart';
import 'package:ssma/services/db_service.dart';

class FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProvider();

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    try {
      final isar = await DBService.getIsarInitialized();
      await isar.writeTxn(() async {
        await isar.clear();
      });
    } catch (_) {}
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
  });
}
