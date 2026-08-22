// test/widget/new_sale_screen_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/screens/new_sale_screen.dart';
import 'package:ssma/services/pdf_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSaleDb implements IDBService {
  final List<Product> products;
  final List<Customer> customers;
  final List<Sale> recordedSales = [];

  _FakeSaleDb({
    required this.products,
    required this.customers,
  });

  @override
  Future<List<Product>> getProducts() async => products;

  @override
  Future<List<Customer>> getCustomers() async => customers;

  @override
  Future<void> recordSale(Sale sale) async {
    recordedSales.add(sale);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = products.indexWhere((p) => p.uuid == product.uuid);
    if (index != -1) {
      products[index] = product;
    }
  }

  @override
  Future<Product?> getProductByUuid(String uuid) async {
    return products.where((p) => p.uuid == uuid).firstOrNull;
  }
}

void main() {
  // Channel for path_provider
  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  const MethodChannel openFileChannel = MethodChannel('open_file');

  Directory? tempDir;

  setUpAll(() async {
    // Ensure binding initialized for platform channel mocking
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    PDFService.generateFiles = false;
    PDFService.openGeneratedFiles = false;

    // Create a temp dir to act as application documents directory for the test run
    tempDir = Directory.systemTemp.createTempSync('new_sale_screen_test_');

    // Mock the platform channel used by path_provider
    pathProviderChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir!.path;
      }
      // handle other path_provider methods if needed
      return null;
    });

    openFileChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'open_file') {
        return '{"type":0,"message":"done"}';
      }
      return null;
    });
  });

  tearDownAll(() async {
    // Remove platform channel mock
    pathProviderChannel.setMockMethodCallHandler(null);
    openFileChannel.setMockMethodCallHandler(null);
    PDFService.generateFiles = true;
    PDFService.openGeneratedFiles = true;

    // Delete temporary directory used for Isar files
    try {
      if (tempDir != null && await tempDir!.exists()) {
        await tempDir!.delete(recursive: true);
      }
    } catch (_) {}
  });

  testWidgets('NewSaleScreen: add Item#1 and complete sale',
      (WidgetTester tester) async {
    final product = Product.create(
      name: 'Item#1',
      salePrice: 100.0,
      purchasePrice: 70.0,
      quantity: 10,
      deviceId: 'test-device',
    );
    final customer = Customer.create(
      name: 'Test Customer',
      phone: '9999999999',
      deviceId: 'test-device',
    );
    final fakeDb = _FakeSaleDb(
      products: [product],
      customers: [customer],
    );

    await tester.pumpWidget(MaterialApp(
      home: NewSaleScreen(dbService: fakeDb),
    ));

    // Wait for async init (loadData) to finish
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Basic UI assertions
    expect(find.text('Create Sale'), findsOneWidget);
    expect(find.text('No items added.'), findsOneWidget);
    expect(find.text('Rs.0.00'), findsWidgets);

    // Fill buyer info
    await tester.enterText(
        find.byKey(const Key('buyerNameField')), 'Test Buyer');
    await tester.enterText(
        find.byKey(const Key('buyerContactField')), '9999999999');

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
    expect(find.textContaining('Rs.100.00'), findsWidgets);

    // Complete sale
    final saveButton = find.byKey(const Key('saveSaleButton'));
    expect(saveButton, findsOneWidget);
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Expect snackbar from _completeSale()
    final visibleText = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .join('\n');
    expect(
      find.text('Sale completed & PDF generated.'),
      findsOneWidget,
      reason: visibleText,
    );
    expect(fakeDb.recordedSales, hasLength(1));
  });
}
