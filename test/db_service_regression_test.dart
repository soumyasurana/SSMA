import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/purchase_item.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/sale_item.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/sync/v2/models/sync_change_log.dart';
import 'package:ssma/sync/v2/services/change_journal.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory testDir;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('ssma_db_regression_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return testDir.path;
      }
      return null;
    });
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

    await DBService.initializeIsar();
    final initializer = SyncInitializerV2();
    initializer.changeJournal = ChangeJournal(
      isar: DBService.isar,
      localDeviceId: 'test-device',
    );
    syncV2 = initializer;
  });

  tearDown(() async {
    syncV2 = null;
    try {
      await DBService.isar.close();
    } catch (_) {}
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  test('deleted sales are hidden and deleteSaleAndRestoreStock is idempotent',
      () async {
    final product = Product.create(
      name: 'Widget',
      salePrice: 10,
      purchasePrice: 6,
      quantity: 10,
      deviceId: 'test-device',
    );
    await DBService.addProduct(product);

    final sale = Sale.create(
      buyerName: 'Cash Buyer',
      buyerContact: '123',
      totalAmount: 20,
      amountReceived: 20,
      date: DateTime.now(),
      saleType: SaleType.cash,
      items: [
        SaleItem.create(
          productUuid: product.uuid,
          productName: product.name,
          quantity: 2,
          unitPrice: 10,
          purchasePrice: 6,
          deviceId: 'test-device',
        ),
      ],
      deviceId: 'test-device',
    );
    await DBService.recordSale(sale);

    expect((await DBService.getProductByUuid(product.uuid))!.quantity, 8);

    await DBService.deleteSaleAndRestoreStock(sale.uuid);
    await DBService.deleteSaleAndRestoreStock(sale.uuid);

    expect(await DBService.getAllSales(), isEmpty);
    expect((await DBService.getProductByUuid(product.uuid))!.quantity, 10);
  });

  test('editing a sale records an UPDATE, not a DELETE plus CREATE', () async {
    final product = Product.create(
      name: 'Bolt',
      salePrice: 10,
      purchasePrice: 4,
      quantity: 10,
      deviceId: 'test-device',
    );
    await DBService.addProduct(product);

    final original = Sale.create(
      buyerName: 'Cash Buyer',
      buyerContact: '123',
      totalAmount: 20,
      amountReceived: 20,
      date: DateTime.now(),
      saleType: SaleType.cash,
      items: [
        SaleItem.create(
          productUuid: product.uuid,
          productName: product.name,
          quantity: 2,
          unitPrice: 10,
          purchasePrice: 4,
          deviceId: 'test-device',
        ),
      ],
      deviceId: 'test-device',
    );
    await DBService.recordSale(original);

    final saved = (await DBService.getAllSales()).single;
    final edited = Sale.create(
      buyerName: 'Cash Buyer',
      buyerContact: '123',
      totalAmount: 30,
      amountReceived: 30,
      date: saved.date,
      saleType: SaleType.cash,
      items: [
        SaleItem.create(
          productUuid: product.uuid,
          productName: product.name,
          quantity: 3,
          unitPrice: 10,
          purchasePrice: 4,
          deviceId: 'test-device',
        ),
      ],
      deviceId: 'test-device',
    )
      ..isarId = saved.isarId
      ..uuid = saved.uuid
      ..version = saved.version;

    await DBService.recordSale(edited);

    final allSaleLogs = await DBService.isar.syncChangeLogs
        .filter()
        .entityTypeEqualTo('Sale')
        .findAll();
    final saleLogs =
        allSaleLogs.where((log) => log.entityId == saved.uuid).toList();
    saleLogs.sort((a, b) => a.changeSeq.compareTo(b.changeSeq));

    expect(saleLogs.map((log) => log.operation), ['CREATE', 'UPDATE']);
    expect((await DBService.getAllSales()).single.version, saved.version + 1);
    expect((await DBService.getProductByUuid(product.uuid))!.quantity, 7);
  });

  test('deleted customer payments are hidden and cannot restore dues twice',
      () async {
    final customer = Customer.create(
      name: 'Asha',
      phone: '999',
      pendingDues: 50,
      deviceId: 'test-device',
    );
    await DBService.addCustomer(customer);

    final payment = CustomerPayment.create(
      customerUuid: customer.uuid,
      customerName: customer.name,
      amountReceived: 10,
      previousDue: 50,
      newDue: 40,
      date: DateTime.now(),
      deviceId: 'test-device',
    );
    await DBService.addCustomerPayment(payment);

    await DBService.deleteCustomerPayment(payment.isarId);
    await DBService.deleteCustomerPayment(payment.isarId);

    expect(await DBService.getCustomerPaymentsByCustomerUuid(customer.uuid),
        isEmpty);
    expect((await DBService.getCustomerById(customer.isarId))!.pendingDues, 50);
  });

  test('deletePurchase hides purchase and reverses product stock', () async {
    final product = Product.create(
      name: 'Nut',
      salePrice: 5,
      purchasePrice: 2,
      quantity: 10,
      deviceId: 'test-device',
    );
    await DBService.addProduct(product);

    final purchase = Purchase.create(
      supplierUuid: 'supplier-1',
      purchaseItems: [
        PurchaseItem.create(
          productUuid: product.uuid,
          productName: product.name,
          purchasePrice: 2,
          quantity: 5,
          deviceId: 'test-device',
        ),
      ],
      totalAmount: 10,
      date: DateTime.now(),
      deviceId: 'test-device',
    );
    await DBService.addPurchase(purchase);

    expect((await DBService.getProductByUuid(product.uuid))!.quantity, 15);

    await DBService.deletePurchase(purchase.isarId);
    await DBService.deletePurchase(purchase.isarId);

    expect(await DBService.getAllPurchases(), isEmpty);
    expect((await DBService.getProductByUuid(product.uuid))!.quantity, 10);
  });
}
