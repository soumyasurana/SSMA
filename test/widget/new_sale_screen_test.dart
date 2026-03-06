// test/widget/new_sale_screen_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/screens/new_sale_screen.dart';
import 'package:ssma/services/db_service.dart';

void main() {
  // Channel for path_provider
  const MethodChannel pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  // Temp directory created for Isar files
  Directory? tempDirForIsar;

  setUpAll(() async {
    // Ensure binding initialized for platform channel mocking
    TestWidgetsFlutterBinding.ensureInitialized();

    // Create a temp dir to act as application documents directory for the test run
    tempDirForIsar = Directory.systemTemp.createTempSync('isar_test_');

    // Mock the platform channel used by path_provider
    pathProviderChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDirForIsar!.path;
      }
      // handle other path_provider methods if needed
      return null;
    });

    // Initialize Isar using your DBService (will use the mocked docs dir)
    await DBService.initializeIsar();
    final isar = DBService.isar;

    // Clear collections safely using generic collection API
    await isar.writeTxn(() async {
      try { await isar.collection<Product>().clear(); } catch (_) {}
      try { await isar.collection<Customer>().clear(); } catch (_) {}
      try { await isar.collection<Sale>().clear(); } catch (_) {}
      try { await isar.collection<Purchase>().clear(); } catch (_) {}
      try { await isar.collection<Supplier>().clear(); } catch (_) {}
      try { await isar.collection<SupplierPayment>().clear(); } catch (_) {}
      try { await isar.collection<CustomerPayment>().clear(); } catch (_) {}
    });

    // Seed product + customer via your DBService helpers
    final product = Product()
      ..name = 'Item#1'
      ..salePrice = 100.0
      ..purchasePrice = 70.0
      ..quantity = 10;
    await DBService.addProduct(product);

    final customer = Customer()
      ..name = 'Test Customer'
      ..phone = '9999999999';
    await DBService.addCustomer(customer);
  });

  tearDownAll(() async {
    // Remove platform channel mock
    pathProviderChannel.setMockMethodCallHandler(null);

    // Close Isar
    try {
      final isar = DBService.isar;
      if (isar.isOpen) await isar.close();
    } catch (_) {}

    // Delete temporary directory used for Isar files
    try {
      if (tempDirForIsar != null && await tempDirForIsar!.exists()) {
        await tempDirForIsar!.delete(recursive: true);
      }
    } catch (_) {}
  });

  testWidgets('NewSaleScreen - real DB: add Item#1 and complete sale', (WidgetTester tester) async {
    // Pump the real screen (it will use DBService.getProducts/getCustomers)
    await tester.pumpWidget(const MaterialApp(home: NewSaleScreen()));

    // Wait for async init (loadData) to finish
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Basic UI assertions
    expect(find.text('Create Sale'), findsOneWidget);
    expect(find.text('No items added.'), findsOneWidget);
    expect(find.text('₹0.00'), findsOneWidget);

    // Fill buyer info
    await tester.enterText(find.byKey(const Key('buyerNameField')), 'Test Buyer');
    await tester.enterText(find.byKey(const Key('buyerContactField')), '9999999999');

    // Find and add seeded product
    final productChip = find.byKey(const Key('productChip_Item#1'));
    expect(productChip, findsOneWidget);
    await tester.tap(productChip);
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(ElevatedButton, 'Add');
    expect(addButton, findsWidgets);
    await tester.tap(addButton.first);
    await tester.pumpAndSettle();

    // Check item added and total updated
    expect(find.text('No items added.'), findsNothing);
    expect(find.byKey(const Key('addedItem_Item#1')), findsOneWidget);
    expect(find.text('₹0.00'), findsNothing);

    // Complete sale
    final saveButton = find.byKey(const Key('saveSaleButton'));
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Expect snackbar from _completeSale()
    expect(find.text('Sale completed & PDF generated.'), findsOneWidget);
  });
}
