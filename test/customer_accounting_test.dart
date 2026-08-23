import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:ssma/services/dashboard_service.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/pdf_service.dart';
import 'package:ssma/services/report_models.dart';
import 'package:ssma/services/report_service.dart';
import 'package:ssma/sync/v2/models/sync_change_log.dart';
import 'package:ssma/sync/v2/services/change_processor.dart';
import 'package:ssma/sync/v2/services/change_journal.dart';
import 'package:ssma/sync/v2/services/conflict_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory testDir;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('ssma_customer_acc_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return testDir.path;
      }
      return null;
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await DBService.isar.close();
    } catch (_) {}
    if (await testDir.exists()) {
      await for (final entry in testDir.list()) {
        await entry.delete(recursive: true);
      }
    }

    await DBService.initializeIsar();
  });

  tearDown(() async {
    try {
      await DBService.isar.close();
    } catch (_) {}
  });

  group('Customer Credit Accounting & Invariants Test Suite', () {
    test('1. Customer creation defaults pendingDues=0, advanceBalance=0',
        () async {
      final customer = Customer.create(
        name: 'Ramesh',
        phone: '9876543210',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final loaded = await DBService.getCustomerById(customer.isarId);
      expect(loaded, isNotNull);
      expect(loaded!.pendingDues, 0.0);
      expect(loaded.advanceBalance, 0.0);
    });

    test(
        '2. Initial credit sale of 100 (0 down payment) creates pendingDues=100',
        () async {
      final customer = Customer.create(
        name: 'Ramesh',
        phone: '9876543210',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        buyerContact: customer.phone,
        totalAmount: 100.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final updatedCustomer = await DBService.getCustomerById(customer.isarId);
      expect(updatedCustomer!.pendingDues, 100.0);
      expect(updatedCustomer.advanceBalance, 0.0);
    });

    test('3. Account payment of 40 reduces pendingDues to 60', () async {
      final customer = Customer.create(
        name: 'Ramesh',
        phone: '9876543210',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 100.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 40.0,
        previousDue: 100.0,
        newDue: 60.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      final updatedCustomer = await DBService.getCustomerById(customer.isarId);
      expect(updatedCustomer!.pendingDues, 60.0);
      expect(updatedCustomer.advanceBalance, 0.0);
    });

    test('4. Overpayment creates advanceBalance (payment of 80 on due of 60)',
        () async {
      final customer = Customer.create(
        name: 'Ramesh',
        phone: '9876543210',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 60.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 80.0,
        previousDue: 60.0,
        newDue: 0.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      final updatedCustomer = await DBService.getCustomerById(customer.isarId);
      expect(updatedCustomer!.pendingDues, 0.0);
      expect(updatedCustomer.advanceBalance, 20.0);
    });

    test(
        '5. Future credit sale consumes advanceBalance (sale of 70 against advance of 20)',
        () async {
      final customer = Customer.create(
        name: 'Suresh',
        phone: '9876543211',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 50.0,
        previousDue: 0.0,
        newDue: 0.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      var updatedCustomer = await DBService.getCustomerById(customer.isarId);
      expect(updatedCustomer!.pendingDues, 0.0);
      expect(updatedCustomer.advanceBalance, 50.0);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 70.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      updatedCustomer = await DBService.getCustomerById(customer.isarId);
      expect(updatedCustomer!.pendingDues, 20.0);
      expect(updatedCustomer.advanceBalance, 0.0);
    });

    test('6. Payment deletion recalculates dues and advance correctly',
        () async {
      final customer = Customer.create(
        name: 'Priya',
        phone: '9876543212',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 100.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 40.0,
        previousDue: 100.0,
        newDue: 60.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      var updatedCustomer = await DBService.getCustomerById(customer.isarId);
      expect(updatedCustomer!.pendingDues, 60.0);

      await DBService.deleteCustomerPayment(payment.isarId);

      updatedCustomer = await DBService.getCustomerById(customer.isarId);
      expect(updatedCustomer!.pendingDues, 100.0);
      expect(updatedCustomer.advanceBalance, 0.0);
    });

    test('7. Overpayment at billing time creates advanceBalance', () async {
      final customer = Customer.create(
        name: 'Karan',
        phone: '9876543213',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 100.0,
        amountReceived: 150.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final updatedCustomer = await DBService.getCustomerById(customer.isarId);
      expect(updatedCustomer!.pendingDues, 0.0);
      expect(updatedCustomer.advanceBalance, 50.0);
    });

    test('8. Reconcile all customer accounts restores mathematical invariants',
        () async {
      final customer = Customer.create(
        name: 'Anita',
        phone: '9876543214',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 200.0,
        amountReceived: 50.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 300.0,
        previousDue: 150.0,
        newDue: 0.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      // Intentionally corrupt cached fields in Isar directly to test reconciliation
      await DBService.isar.writeTxn(() async {
        customer.pendingDues = 999.0;
        customer.advanceBalance = 999.0;
        await DBService.isar.customers.put(customer);
      });

      await DBService.reconcileAllCustomerAccounts();

      final restoredCustomer = await DBService.getCustomerById(customer.isarId);
      expect(restoredCustomer!.pendingDues, 0.0);
      expect(restoredCustomer.advanceBalance, 150.0);
    });

    test(
        '9. Customer ledger PDF generation executes cleanly with running balances',
        () async {
      final customer = Customer.create(
        name: 'Sita',
        phone: '9876543215',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 500.0,
        amountReceived: 100.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now().subtract(const Duration(days: 2)),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 600.0,
        previousDue: 400.0,
        newDue: 0.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      final updatedCustomer =
          (await DBService.getCustomerById(customer.isarId))!;
      expect(updatedCustomer.pendingDues, 0.0);
      expect(updatedCustomer.advanceBalance, 200.0);

      // Verify generateCustomerLedgerPdf completes without throwing
      await PDFService.generateCustomerLedgerPdf(customer: updatedCustomer);
    });

    test(
        '10. CustomerSyncHandler preserves locally-computed pendingDues and advanceBalance',
        () async {
      final customer = Customer.create(
        name: 'Kavita',
        phone: '9876543216',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);
      final localAdvance = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 100.0,
        previousDue: 0.0,
        newDue: 0.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(localAdvance);
      final locallyComputed =
          (await DBService.getCustomerById(customer.isarId))!;

      final incomingPayload = locallyComputed.toJson();
      // Remote payload has stale cached balances (e.g. pendingDues=500, advanceBalance=0)
      incomingPayload['pending_dues'] = 500.0;
      incomingPayload['advance_balance'] = 0.0;
      incomingPayload['version'] = locallyComputed.version + 1;
      incomingPayload['updated_at'] =
          DateTime.now().add(const Duration(minutes: 1)).toIso8601String();

      final handler = CustomerSyncHandler();
      final resolver = ConflictResolver();

      await DBService.isar.writeTxn(() async {
        await handler.applyChange(
            incomingPayload, 'UPDATE', resolver, DBService.isar);
      });

      final syncedCustomer =
          (await DBService.getCustomerById(customer.isarId))!;
      // Local derived balance must NOT be overwritten by remote stale balances
      expect(syncedCustomer.pendingDues, 0.0);
      expect(syncedCustomer.advanceBalance, 100.0);
    });

    test(
        '11. Customer deletion soft-deletes record and excludes from getCustomers',
        () async {
      final customer = Customer.create(
        name: 'DeleteMe',
        phone: '1112223333',
        deviceId: 'test-device',
      );
      await DBService.addCustomer(customer);

      final activeBefore = await DBService.getCustomers();
      expect(activeBefore.any((c) => c.uuid == customer.uuid), true);

      await DBService.deleteCustomer(customer.uuid, isarId: customer.isarId);

      final activeAfter = await DBService.getCustomers();
      expect(activeAfter.any((c) => c.uuid == customer.uuid), false);

      final isarCustomer = await DBService.getCustomerById(customer.isarId);
      expect(isarCustomer!.deleted, true);
    });
  });

  group('Defensive Invariants & Non-Finite (NaN) Accounting Safety Tests', () {
    test('1. Customer with valid dues can be deleted cleanly', () async {
      final customer =
          Customer.create(name: 'DueUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);
      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 150.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final loaded = (await DBService.getCustomerById(customer.isarId))!;
      expect(loaded.pendingDues, 150.0);

      await DBService.deleteCustomer(customer.uuid, isarId: customer.isarId);
      final deleted = (await DBService.getCustomerById(customer.isarId))!;
      expect(deleted.deleted, true);
      expect(deleted.pendingDues.isFinite, true);
      expect(deleted.pendingDues, 150.0);
    });

    test('2. Customer with valid advance can be deleted cleanly', () async {
      final customer =
          Customer.create(name: 'AdvUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);
      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 200.0,
        previousDue: 0.0,
        newDue: 0.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      final loaded = (await DBService.getCustomerById(customer.isarId))!;
      expect(loaded.advanceBalance, 200.0);

      await DBService.deleteCustomer(customer.uuid, isarId: customer.isarId);
      final deleted = (await DBService.getCustomerById(customer.isarId))!;
      expect(deleted.deleted, true);
      expect(deleted.advanceBalance.isFinite, true);
      expect(deleted.advanceBalance, 200.0);
    });

    test(
        '3. Customer with corrupted NaN accounting state can be safely repaired and deleted',
        () async {
      final customer =
          Customer.create(name: 'CorruptUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 300.0,
        amountReceived: 50.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      // Force corrupt pendingDues and advanceBalance directly in DB with NaN/Infinity
      await DBService.isar.writeTxn(() async {
        customer.pendingDues = double.nan;
        customer.advanceBalance = double.infinity;
        await DBService.isar.customers.put(customer);
      });

      // Verify deleteCustomer detects & repairs NaN using sales history (netPosition = 250)
      await DBService.deleteCustomer(customer.uuid, isarId: customer.isarId);

      final deleted = (await DBService.getCustomerById(customer.isarId))!;
      expect(deleted.deleted, true);
      expect(deleted.pendingDues.isFinite, true);
      expect(deleted.advanceBalance.isFinite, true);
      expect(deleted.pendingDues, 250.0);
      expect(deleted.advanceBalance, 0.0);
    });

    test('4. Recalculation never produces NaN even with corrupted sales',
        () async {
      final customer =
          Customer.create(name: 'RecalcNaNUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 100.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      // Corrupt sale record in Isar directly with NaN
      await DBService.isar.writeTxn(() async {
        sale.totalAmount = double.nan;
        sale.amountReceived = double.nan;
        await DBService.isar.sales.put(sale);
      });

      final recalculated =
          await DBService.recalculateCustomerAccount(customer.uuid);
      expect(recalculated, isNotNull);
      expect(recalculated!.pendingDues.isFinite, true);
      expect(recalculated.advanceBalance.isFinite, true);
      expect(recalculated.pendingDues.isNaN, false);
      expect(recalculated.advanceBalance.isNaN, false);
      expect(recalculated.pendingDues >= 0, true);
      expect(recalculated.advanceBalance >= 0, true);
    });

    test('5. Recalculation never produces Infinity', () async {
      final customer =
          Customer.create(name: 'RecalcInfUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 100.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      // Corrupt sale with Infinity
      await DBService.isar.writeTxn(() async {
        sale.totalAmount = double.infinity;
        sale.amountReceived = double.negativeInfinity;
        await DBService.isar.sales.put(sale);
      });

      final recalculated =
          await DBService.recalculateCustomerAccount(customer.uuid);
      expect(recalculated, isNotNull);
      expect(recalculated!.pendingDues.isFinite, true);
      expect(recalculated.advanceBalance.isFinite, true);
      expect(recalculated.pendingDues, 0.0);
      expect(recalculated.advanceBalance, 0.0);
    });

    test('6. Zero/invalid monetary inputs cannot propagate NaN to customer',
        () async {
      final customer =
          Customer.create(name: 'ZeroPropUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      await DBService.updateCustomerDues(customer.isarId, double.nan);
      var reloaded = (await DBService.getCustomerById(customer.isarId))!;
      expect(reloaded.pendingDues.isFinite, true);
      expect(reloaded.advanceBalance.isFinite, true);
      expect(reloaded.pendingDues, 0.0);
      expect(reloaded.advanceBalance, 0.0);

      await DBService.updateCustomerDuesByUuid(customer.uuid, double.infinity);
      reloaded = (await DBService.getCustomerById(customer.isarId))!;
      expect(reloaded.pendingDues.isFinite, true);
      expect(reloaded.advanceBalance.isFinite, true);
      expect(reloaded.pendingDues, 0.0);
      expect(reloaded.advanceBalance, 0.0);
    });

    test('7. Startup reconciliation removes invalid customer accounting state',
        () async {
      final customer = Customer.create(
          name: 'StartupReconcileUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      await DBService.isar.writeTxn(() async {
        customer.pendingDues = double.nan;
        customer.advanceBalance = -50.0;
        await DBService.isar.customers.put(customer);
      });

      await DBService.reconcileAllCustomerAccounts();

      final repaired = (await DBService.getCustomerById(customer.isarId))!;
      expect(repaired.pendingDues.isFinite, true);
      expect(repaired.advanceBalance.isFinite, true);
      expect(repaired.pendingDues, 0.0);
      expect(repaired.advanceBalance, 0.0);
    });

    test('8. Sync cannot introduce non-finite customer balances', () async {
      final customer =
          Customer.create(name: 'SyncUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      final payload = customer.toJson();
      payload['pending_dues'] = double.nan;
      payload['advance_balance'] = double.infinity;
      payload['version'] = customer.version + 1;
      payload['updated_at'] =
          DateTime.now().add(const Duration(minutes: 1)).toIso8601String();

      final handler = CustomerSyncHandler();
      final resolver = ConflictResolver();

      await DBService.isar.writeTxn(() async {
        await handler.applyChange(payload, 'UPDATE', resolver, DBService.isar);
      });

      final synced = (await DBService.getCustomerById(customer.isarId))!;
      expect(synced.pendingDues.isFinite, true);
      expect(synced.advanceBalance.isFinite, true);
      expect(synced.pendingDues, 0.0);
      expect(synced.advanceBalance, 0.0);
    });

    test('9. Customer deletion still works after accounting reconciliation',
        () async {
      final customer =
          Customer.create(name: 'ReconcileDeleteUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);
      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 100.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      await DBService.reconcileAllCustomerAccounts();

      await DBService.deleteCustomer(customer.uuid, isarId: customer.isarId);
      final deleted = (await DBService.getCustomerById(customer.isarId))!;
      expect(deleted.deleted, true);
      expect(deleted.pendingDues.isFinite, true);
      expect(deleted.advanceBalance.isFinite, true);
    });

    test(
        '10. Customer advance of 30,000 offset by 10,000 sale leaves 20,000 advance and generates PDF statement',
        () async {
      final customer =
          Customer.create(name: 'AdvanceOffsetUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 30000.0,
        previousDue: 0.0,
        newDue: 0.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      var updated = (await DBService.getCustomerById(customer.isarId))!;
      expect(updated.advanceBalance, 30000.0);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 10000.0,
        amountReceived: 0.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      updated = (await DBService.getCustomerById(customer.isarId))!;
      expect(updated.pendingDues, 0.0);
      expect(updated.advanceBalance, 20000.0);

      // Verify PDF generation executes cleanly with offset note
      await PDFService.generateCustomerLedgerPdf(customer: updated);
    });

    test(
        '11. Stale cached balances with no active transactions reconcile to zero',
        () async {
      final customer =
          Customer.create(name: 'StaleCacheUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      await DBService.isar.writeTxn(() async {
        customer.pendingDues = 1250.0;
        customer.advanceBalance = 300.0;
        await DBService.isar.customers.put(customer);
      });

      final recalculated =
          await DBService.recalculateCustomerAccount(customer.uuid);
      expect(recalculated!.pendingDues, 0.0);
      expect(recalculated.advanceBalance, 0.0);
    });

    test('12. Deleted sales and deleted payments are excluded from balance',
        () async {
      final customer =
          Customer.create(name: 'DeletedTxnUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 500.0,
        amountReceived: 100.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 150.0,
        previousDue: 400.0,
        newDue: 250.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      await DBService.deleteSale(sale.isarId);
      await DBService.deleteCustomerPayment(payment.isarId);

      final recalculated =
          await DBService.recalculateCustomerAccount(customer.uuid);
      expect(recalculated!.pendingDues, 0.0);
      expect(recalculated.advanceBalance, 0.0);
    });

    test('13. Sync-applied transactions repair stale customer balance payloads',
        () async {
      EntityRegistry.registerAll(isar: DBService.isar);
      final journal = ChangeJournal(
        isar: DBService.isar,
        localDeviceId: 'local-device',
      );
      final processor = ChangeProcessor(
        isar: DBService.isar,
        journal: journal,
        conflictResolver: ConflictResolver(),
      );

      final customer =
          Customer.create(name: 'SyncedUser', deviceId: 'remote-device');
      customer.pendingDues = 999.0;
      customer.advanceBalance = 999.0;
      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 300.0,
        amountReceived: 50.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'remote-device',
      );
      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 75.0,
        previousDue: 250.0,
        newDue: 175.0,
        date: DateTime.now(),
        deviceId: 'remote-device',
      );

      SyncChangeLog remoteChange(
        int seq,
        String entityType,
        String entityId,
        Map<String, dynamic> payload,
      ) {
        return SyncChangeLog()
          ..changeId = 'remote-change-$seq'
          ..changeSeq = seq
          ..entityType = entityType
          ..entityId = entityId
          ..operation = 'CREATE'
          ..entityVersion = 1
          ..originDeviceId = 'remote-device'
          ..timestampMs = DateTime.now().millisecondsSinceEpoch + seq
          ..payload = jsonEncode(payload)
          ..acknowledged = false;
      }

      await processor.processBatch([
        remoteChange(1, 'Customer', customer.uuid, customer.toJson()),
        remoteChange(2, 'Sale', sale.uuid, sale.toJson()),
        remoteChange(3, 'CustomerPayment', payment.uuid, payment.toJson()),
      ]);

      final synced = (await DBService.isar.customers
          .filter()
          .uuidEqualTo(customer.uuid)
          .findFirst())!;
      expect(synced.pendingDues, 175.0);
      expect(synced.advanceBalance, 0.0);
    });

    test('14. List, dashboard, and reports refresh stale cached balances',
        () async {
      final customer =
          Customer.create(name: 'DisplayUser', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      final sale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 200.0,
        amountReceived: 25.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(sale);

      final payment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 50.0,
        previousDue: 175.0,
        newDue: 125.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(payment);

      await DBService.isar.writeTxn(() async {
        customer.pendingDues = 999.0;
        customer.advanceBalance = 0.0;
        await DBService.isar.customers.put(customer);
      });

      final listCustomer = (await DBService.getCustomers())
          .singleWhere((c) => c.uuid == customer.uuid);
      expect(listCustomer.pendingDues, 125.0);
      expect(listCustomer.advanceBalance, 0.0);

      final dashboard = await DashboardService.getDashboardData(
        range: DashboardDateRange.today,
      );
      expect(dashboard.receivablesTotal, 125.0);
      expect(dashboard.topReceivables.single.outstandingAmount, 125.0);

      final reportRange = ReportService.getPresetRange(ReportTimePreset.today);
      final report = await ReportService.generateReport(
        startDate: reportRange.start,
        endDate: reportRange.end,
        presetLabel: 'Today',
      );
      expect(report.totalCustomerReceivables, 125.0);
      expect(report.topCustomersByOutstanding.first.currentOutstanding, 125.0);
    });

    test(
        '15. Legacy account payment injected into Sale.amountReceived is not double-counted',
        () async {
      final customer =
          Customer.create(name: 'Bablu Jaipur', deviceId: 'test-device');
      await DBService.addCustomer(customer);

      final fullyPaidJuneSale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 69773.0,
        amountReceived: 69773.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime(2026, 6, 20, 0, 3),
        deviceId: 'test-device',
      );
      await DBService.recordSale(fullyPaidJuneSale);

      final legacyMutatedJulySale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 122200.0,
        // Genuine billing-time receipt was 50,000. A later 72,200 account
        // payment was also injected here, making this sale look fully paid.
        amountReceived: 122200.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime(2026, 7, 29, 0, 4),
        deviceId: 'test-device',
      );
      await DBService.recordSale(legacyMutatedJulySale);

      final duplicatedAccountPayment = CustomerPayment.create(
        customerUuid: customer.uuid,
        customerName: customer.name,
        amountReceived: 72200.0,
        previousDue: 72200.0,
        newDue: 0.0,
        date: DateTime(2026, 7, 30),
        deviceId: 'test-device',
      );
      await DBService.isar.writeTxn(() async {
        await DBService.isar.customerPayments.put(duplicatedAccountPayment);
      });

      final latestCreditSale = Sale.create(
        customerUuid: customer.uuid,
        buyerName: customer.name,
        totalAmount: 90392.50,
        amountReceived: 30390.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime(2026, 8, 21, 23, 44),
        deviceId: 'test-device',
      );
      await DBService.recordSale(latestCreditSale);

      await DBService.isar.writeTxn(() async {
        customer.pendingDues = 0.0;
        customer.advanceBalance = 12197.50;
        await DBService.isar.customers.put(customer);
      });

      final recalculated =
          await DBService.recalculateCustomerAccount(customer.uuid);
      expect(recalculated!.pendingDues, 60002.50);
      expect(recalculated.advanceBalance, 0.0);

      await DBService.reconcileAllCustomerAccounts();
      final afterStartupReconcile =
          (await DBService.getCustomerById(customer.isarId))!;
      expect(afterStartupReconcile.pendingDues, 60002.50);
      expect(afterStartupReconcile.advanceBalance, 0.0);

      final listCustomer = (await DBService.getCustomers())
          .singleWhere((c) => c.uuid == customer.uuid);
      expect(listCustomer.pendingDues, 60002.50);
      expect(listCustomer.advanceBalance, 0.0);
    });

    test(
        '16. Normal positive due and genuine advance patterns keep one-sided balances',
        () async {
      final dueCustomer =
          Customer.create(name: 'Due Pattern', deviceId: 'test-device');
      await DBService.addCustomer(dueCustomer);
      final dueSale = Sale.create(
        customerUuid: dueCustomer.uuid,
        buyerName: dueCustomer.name,
        totalAmount: 1000.0,
        amountReceived: 250.0,
        saleType: SaleType.credit,
        items: [],
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.recordSale(dueSale);
      final duePayment = CustomerPayment.create(
        customerUuid: dueCustomer.uuid,
        customerName: dueCustomer.name,
        amountReceived: 300.0,
        previousDue: 750.0,
        newDue: 450.0,
        date: DateTime.now().add(const Duration(minutes: 1)),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(duePayment);

      final recalculatedDue =
          await DBService.recalculateCustomerAccount(dueCustomer.uuid);
      expect(recalculatedDue!.pendingDues, 450.0);
      expect(recalculatedDue.advanceBalance, 0.0);

      final advanceCustomer =
          Customer.create(name: 'Advance Pattern', deviceId: 'test-device');
      await DBService.addCustomer(advanceCustomer);
      final advancePayment = CustomerPayment.create(
        customerUuid: advanceCustomer.uuid,
        customerName: advanceCustomer.name,
        amountReceived: 500.0,
        previousDue: 0.0,
        newDue: 0.0,
        date: DateTime.now(),
        deviceId: 'test-device',
      );
      await DBService.addCustomerPayment(advancePayment);

      final recalculatedAdvance =
          await DBService.recalculateCustomerAccount(advanceCustomer.uuid);
      expect(recalculatedAdvance!.pendingDues, 0.0);
      expect(recalculatedAdvance.advanceBalance, 500.0);
    });

    test(
        '17. Inventory Product and Purchase models sanitize non-finite NaN values',
        () {
      final p = Product();
      p.name = 'TestProduct';
      p.salePrice = double.nan;
      p.purchasePrice = double.infinity;
      p.quantity = -10;

      final json = p.toJson();
      expect(json['sale_price'], 0.0);
      expect(json['purchase_price'], 0.0);
      expect((json['sale_price'] as double).isFinite, true);

      final purchaseJson = {
        'id': 'test-id',
        'supplier_id': 'supp-id',
        'total_amount': double.nan,
        'amount_paid': double.infinity,
        'purchase_date': DateTime.now().toIso8601String(),
        'version': 1,
        'device_id': 'test',
        'is_deleted': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final purchase = Purchase.fromJson(purchaseJson);
      expect(purchase.totalAmount, 0.0);
      expect(purchase.amountPaid, 0.0);
      expect(purchase.totalAmount.isFinite, true);
    });
  });
}
