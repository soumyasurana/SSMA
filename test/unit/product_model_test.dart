import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:ssma/models/product.dart';

void main() {
  group('Product Model Unit Tests', () {
    
    // --- Test 1: Default Constructor ---
    test('Default constructor initializes all fields correctly', () {
      // ACT
      final product = Product();

      // ASSERT
      expect(product.isarId, Isar.autoIncrement,
          reason: 'isarId should be autoIncrement');
      expect(product.salePrice, 0.0, reason: 'salePrice should default to 0.0');
      expect(product.purchasePrice, 0.0, reason: 'purchasePrice should default to 0.0');
      expect(product.deleted, isFalse, reason: 'deleted should default to false');
      
      // Check timestamp initialization (should be close to now)
      expect(product.createdAt.difference(DateTime.now()).inSeconds, lessThan(1));
    });

    // --- Test 2: Named Factory/Constructor `create` ---
    test('create constructor initializes required fields and metadata', () {
      // ARRANGE
      const testName = 'TestItem';
      const testSalePrice = 15.50;
      const testPurchasePrice = 10.00;
      const testQuantity = 50;
      
      // ACT
      final product = Product.create(
        name: testName,
        salePrice: testSalePrice,
        purchasePrice: testPurchasePrice,
        quantity: testQuantity,
        deviceId: 'test-device',
      );

      // ASSERT
      // 1. Check required values
      expect(product.name, testName);
      expect(product.salePrice, testSalePrice);
      expect(product.purchasePrice, testPurchasePrice);
      expect(product.quantity, testQuantity);
      
      // 2. Check default/metadata values set by the constructor
      expect(product.uuid, isNotEmpty, reason: 'uuid should be generated');
      expect(product.deleted, isFalse, reason: 'deleted must be explicitly false');

      // 3. Check timestamps set during creation
      expect(product.createdAt.difference(product.updatedAt), Duration.zero);
    });

    // --- Test 3: Named Factory/Constructor `create` with optional field ---
    test('create constructor handles optional imagePath field', () {
      // ARRANGE
      const testImagePath = 'assets/images/test.png';
      
      // ACT
      final product = Product.create(
        name: 'Image Item',
        salePrice: 1.0,
        purchasePrice: 0.5,
        quantity: 1,
        imagePath: testImagePath,
        deviceId: 'test-device',
      );

      // ASSERT
      expect(product.imagePath, testImagePath);
    });
  });
}
