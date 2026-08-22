import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/godown_item.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/purchase_item.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/sale_item.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/report_models.dart';
import 'package:ssma/services/report_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory testDir;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('ssma_report_unit_');
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return testDir.path;
      }
      return null;
    });
    try {
      await DBService.isar.close();
    } catch (_) {}
    if (await testDir.exists()) {
      await for (final entry in testDir.list()) {
        await entry.delete(recursive: true);
      }
    }
    await DBService.getIsarInitialized();
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    try {
      await DBService.isar.close();
    } catch (_) {}
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  group('ReportService Business Intelligence Tests', () {
    test('Calculates P&L, Gross Profit, Cash Flow, and Inventory Valuations correctly', () async {
      final now = DateTime.now();

      // 1. Create Products
      final p1 = Product.create(
        name: 'Basmati Rice 1kg',
        salePrice: 120.0,
        purchasePrice: 80.0,
        quantity: 50,
        deviceId: 'test-dev',
      );
      final p2 = Product.create(
        name: 'Sunflower Oil 1L',
        salePrice: 180.0,
        purchasePrice: 140.0,
        quantity: 20,
        deviceId: 'test-dev',
      );
      await DBService.addProduct(p1);
      await DBService.addProduct(p2);

      // 2. Create Godown Items
      final g1 = GodownItem.create(
        name: 'Basmati Rice Bulk 50kg',
        quantity: 10,
        unitCost: 3500.0,
        deviceId: 'test-dev',
      );
      await DBService.addGodownItem(g1);

      // 3. Create Customer
      final cust = Customer.create(
        name: 'Ramesh Sharma',
        phone: '9876543210',
        deviceId: 'test-dev',
      );
      await DBService.addCustomer(cust);

      // 4. Create Supplier
      final supp = Supplier.create(
        name: 'Agro Distributors Ltd',
        contact: '9988776655',
        deviceId: 'test-dev',
      );
      await DBService.addSupplier(supp);

      // 5. Record Cash Sale
      final cashSale = Sale.create(
        items: [
          SaleItem.create(
            productUuid: p1.uuid,
            productName: p1.name,
            quantity: 10,
            unitPrice: 120.0,
            purchasePrice: 80.0,
            deviceId: 'test-dev',
          ),
        ],
        totalAmount: 1200.0,
        amountReceived: 1200.0,
        saleType: SaleType.cash,
        date: now,
        deviceId: 'test-dev',
      );
      await DBService.recordSale(cashSale);

      // 6. Record Credit Sale to Customer
      final creditSale = Sale.create(
        items: [
          SaleItem.create(
            productUuid: p2.uuid,
            productName: p2.name,
            quantity: 5,
            unitPrice: 180.0,
            purchasePrice: 140.0,
            deviceId: 'test-dev',
          ),
        ],
        totalAmount: 900.0,
        amountReceived: 400.0,
        saleType: SaleType.credit,
        customerUuid: cust.uuid,
        buyerName: cust.name,
        buyerContact: cust.phone,
        date: now,
        deviceId: 'test-dev',
      );
      await DBService.recordSale(creditSale);

      // 7. Record Customer Payment
      final custPayment = CustomerPayment.create(
        customerUuid: cust.uuid,
        customerName: cust.name,
        amountReceived: 200.0,
        previousDue: 500.0,
        newDue: 300.0,
        date: now,
        deviceId: 'test-dev',
      );
      await DBService.addCustomerPayment(custPayment);
      creditSale.amountReceived += 200.0;
      await DBService.updateSale(creditSale);

      // 8. Record Purchase from Supplier
      final purchase = Purchase.create(
        supplierUuid: supp.uuid,
        purchaseItems: [
          PurchaseItem.create(
            productUuid: p1.uuid,
            productName: p1.name,
            quantity: 20,
            purchasePrice: 80.0,
            deviceId: 'test-dev',
          ),
        ],
        totalAmount: 1600.0,
        date: now,
        deviceId: 'test-dev',
      );
      await DBService.addPurchase(purchase);

      // 9. Record Supplier Payment
      final suppPayment = SupplierPayment.create(
        supplierUuid: supp.uuid,
        amount: 1000.0,
        date: now,
        deviceId: 'test-dev',
      );
      await DBService.addSupplierPayment(suppPayment);

      // Generate Report for Today
      final range = ReportService.getPresetRange(ReportTimePreset.today);
      final report = await ReportService.generateReport(
        startDate: range.start,
        endDate: range.end,
        presetLabel: 'Today',
      );

      // Verify Revenue: 1200 + 900 = 2100
      expect(report.grossSales, 2100.0);
      expect(report.totalOrders, 2);
      expect(report.averageOrderValue, 1050.0);
      expect(report.totalItemsSold, 15);

      // Verify COGS: (10 * 80) + (5 * 140) = 800 + 700 = 1500
      expect(report.cogs, 1500.0);

      // Verify Gross Profit: 2100 - 1500 = 600
      expect(report.grossProfit, 600.0);
      expect(report.profitMarginPercentage, closeTo((600 / 2100) * 100, 0.01));

      // Verify Cash Flow
      // Inflow: 1200 (sale 1) + 600 (sale 2) + 200 (customer payment) = 2000
      expect(report.totalCashInflow, 2000.0);
      // Outflow: 1000 (supplier payment)
      expect(report.totalCashOutflow, 1000.0);
      expect(report.netCashFlow, 1000.0);

      // Verify Working Capital
      // Customer Receivables: 500 - 200 = 300
      expect(report.totalCustomerReceivables, 300.0);
      // Supplier Payables: 1600 - 1000 = 600
      expect(report.totalSupplierPayables, 600.0);
      expect(report.netWorkingCapitalPosition, -300.0);

      // Verify Godown Valuation: 10 * 3500 = 35000
      expect(report.godownInventoryValuationAtCost, 35000.0);
      expect(report.totalGodownStockUnits, 10);

      // Verify Top Products
      expect(report.topProductsByRevenue.length, 2);
      expect(report.topProductsByRevenue.first.productName, 'Basmati Rice 1kg');
    });
  });
}
