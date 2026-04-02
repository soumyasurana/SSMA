import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:ssma/models/customer.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/change_log.dart';
import 'package:ssma/models/item.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/sale_item.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';

class DBService {
  static Isar? _isarInstance;
  static const _uuid = Uuid();

  static Future<void> _putProductSafe(Product product) async {
    final uuidValue = product.uuid.trim();
    if (uuidValue.isEmpty) {
      // Existing legacy rows may not have UUID populated.
      // Update by Isar ID in that case to avoid creating a duplicate row.
      if (product.isarId != Isar.autoIncrement) {
        await isar.products.put(product);
        return;
      }
      product.uuid = _uuid.v4();
    }
    await isar.products.putByUuid(product);
  }

  static Future<void> initializeIsar() async {
    if (_isarInstance != null && _isarInstance!.isOpen) {
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isarInstance = await Isar.open(
      [
        CustomerSchema,
        ProductSchema,
        ItemSchema,
        ChangeLogSchema,
        SaleSchema,
        PurchaseSchema,
        CustomerPaymentSchema,
        SupplierSchema,
        SupplierPaymentSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
    );
  }

  static Isar get isar {
    if (_isarInstance == null || !_isarInstance!.isOpen) {
      throw Exception('Isar database has not been initialized.');
    }
    return _isarInstance!;
  }

  static Future<Isar> getIsarInitialized() async {
    await initializeIsar();
    return isar;
  }

  static Future<List<Product>> getProducts() async {
    return isar.products.filter().deletedEqualTo(false).findAll();
  }

  static Future<void> addProduct(Product product) async {
    product.createdAt = DateTime.now();
    product.updatedAt = DateTime.now();
    product.deleted = false;

    await isar.writeTxn(() async {
      await _putProductSafe(product);
    });
  }

  static Future<void> updateProduct(Product product) async {
    product.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await _putProductSafe(product);
    });
  }

  static Future<void> deleteProduct(String productUuid) async {
    final product =
        await isar.products.filter().uuidEqualTo(productUuid).findFirst();
    if (product == null) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.products.delete(product.isarId);
    });
  }

  static Future<void> deleteProductByIsarId(int id) async {
    await isar.writeTxn(() async {
      await isar.products.delete(id);
    });
  }

  static Future<Product?> getProductById(int id) async {
    return isar.products.get(id);
  }

  static Future<List<Customer>> getCustomers() async {
    return isar.customers.filter().deletedEqualTo(false).findAll();
  }

  static Future<void> addCustomer(Customer customer) async {
    customer.createdAt = DateTime.now();
    customer.updatedAt = DateTime.now();
    customer.deleted = false;

    await isar.writeTxn(() async {
      await isar.customers.put(customer);
    });
  }

  static Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.customers.put(customer);
    });
  }

  static Future<void> deleteCustomer(String customerUuid) async {
    final customer =
        await isar.customers.filter().uuidEqualTo(customerUuid).findFirst();
    if (customer == null) {
      return;
    }

    await isar.writeTxn(() async {
      // Soft-delete to keep historical links stable and avoid relational side-effects.
      customer.deleted = true;
      customer.updatedAt = DateTime.now();
      customer.isSynced = false;
      customer.version += 1;
      await isar.customers.put(customer);
    });
  }

  static Future<Customer?> getCustomerById(int id) async {
    return isar.customers.get(id);
  }

  static Future<void> addCustomerPayment(CustomerPayment payment) async {
    await isar.writeTxn(() async {
      await isar.customerPayments.put(payment);
    });
  }

  static Future<void> deleteCustomerPayment(int paymentIsarId) async {
    await isar.writeTxn(() async {
      final payment = await isar.customerPayments.get(paymentIsarId);
      if (payment == null) {
        return;
      }

      final customer = await isar.customers
          .filter()
          .uuidEqualTo(payment.customerUuid)
          .findFirst();
      if (customer != null) {
        customer.pendingDues += payment.amountReceived;
        customer.updatedAt = DateTime.now();
        customer.isSynced = false;
        await isar.customers.put(customer);
      }

      await isar.customerPayments.delete(paymentIsarId);
    });
  }

  static Future<List<CustomerPayment>> getCustomerPaymentsByCustomerUuid(
      String customerUuid) async {
    return isar.customerPayments
        .filter()
        .customerUuidEqualTo(customerUuid)
        .sortByDateDesc()
        .findAll();
  }

  static Future<List<CustomerPayment>> getCustomerPaymentsByCustomerId(
      int customerId) async {
    final customer = await isar.customers.get(customerId);
    if (customer == null) {
      return [];
    }
    return getCustomerPaymentsByCustomerUuid(customer.uuid);
  }

  static Future<void> recordSale(Sale sale) async {
    await isar.writeTxn(() async {
      if (sale.isarId != Isar.autoIncrement) {
        final oldSale = await isar.sales.get(sale.isarId);
        if (oldSale != null) {
          for (final item in oldSale.items) {
            final product = await isar.products
                .filter()
                .uuidEqualTo(item.productUuid)
                .findFirst();
            if (product != null) {
              product.quantity += item.quantity;
              product.updatedAt = DateTime.now();
              product.isSynced = false;
              await _putProductSafe(product);
            }
          }

          if (oldSale.saleType == SaleType.credit && oldSale.customerUuid != null) {
            final customer = await isar.customers
                .filter()
                .uuidEqualTo(oldSale.customerUuid!)
                .findFirst();
            if (customer != null) {
              customer.pendingDues -= (oldSale.totalAmount - oldSale.amountReceived);
              if (customer.pendingDues < 0) {
                customer.pendingDues = 0;
              }
              customer.updatedAt = DateTime.now();
              customer.isSynced = false;
              await isar.customers.put(customer);
            }
          }

          await isar.sales.delete(oldSale.isarId);
        }
      }

      for (final item in sale.items) {
        final product = await isar.products
            .filter()
            .uuidEqualTo(item.productUuid)
            .findFirst();
        if (product != null) {
          product.quantity -= item.quantity;
          if (product.quantity < 0) {
            product.quantity = 0;
          }
          product.updatedAt = DateTime.now();
          product.isSynced = false;
          await _putProductSafe(product);
        }
      }

      if (sale.saleType == SaleType.credit && sale.customerUuid != null) {
        final customer = await isar.customers
            .filter()
            .uuidEqualTo(sale.customerUuid!)
            .findFirst();
        if (customer != null) {
          customer.pendingDues += (sale.totalAmount - sale.amountReceived);
          customer.updatedAt = DateTime.now();
          customer.isSynced = false;
          await isar.customers.put(customer);
        }
      }

      await isar.sales.put(sale);
    });
  }

  static Future<void> updateSale(Sale sale) async {
    sale.updatedAt = DateTime.now();
    sale.isSynced = false;
    await isar.writeTxn(() async {
      await isar.sales.put(sale);
    });
  }

  static Future<Sale?> getSaleById(int id) async {
    return isar.sales.get(id);
  }

  static Future<void> deleteSale(int id) async {
    await isar.writeTxn(() async {
      await isar.sales.delete(id);
    });
  }

  static Future<List<Sale>> getAllSales() async {
    return isar.sales.where().sortByDateDesc().findAll();
  }

  static Future<void> deleteSaleAndRestoreStock(String saleUuid) async {
    await isar.writeTxn(() async {
      final sale = await isar.sales.filter().uuidEqualTo(saleUuid).findFirst();
      if (sale == null) {
        return;
      }

      for (final item in sale.items) {
        final product = await isar.products
            .filter()
            .uuidEqualTo(item.productUuid)
            .findFirst();
        if (product != null) {
          product.quantity += item.quantity;
          product.updatedAt = DateTime.now();
          product.isSynced = false;
          await _putProductSafe(product);
        }
      }

      if (sale.saleType == SaleType.credit && sale.customerUuid != null) {
        final customer = await isar.customers
            .filter()
            .uuidEqualTo(sale.customerUuid!)
            .findFirst();
        if (customer != null) {
          customer.pendingDues -= (sale.totalAmount - sale.amountReceived);
          if (customer.pendingDues < 0) {
            customer.pendingDues = 0;
          }
          customer.updatedAt = DateTime.now();
          customer.isSynced = false;
          await isar.customers.put(customer);
        }
      }

      await isar.sales.delete(sale.isarId);
    });
  }

  static Future<List<SaleItem>> getSaleItemsForSaleId(int saleId) async {
    final sale = await isar.sales.get(saleId);
    return sale?.items.toList() ?? [];
  }

  static Future<void> updateSalePayment({
    String? saleUuid,
    int? saleId,
    required double newAmountReceived,
  }) async {
    Sale? sale;
    if (saleUuid != null) {
      sale = await isar.sales.filter().uuidEqualTo(saleUuid).findFirst();
    } else if (saleId != null) {
      sale = await isar.sales.get(saleId);
    }
    if (sale == null) {
      return;
    }
    final loadedSale = sale;

    final delta = newAmountReceived - loadedSale.amountReceived;
    loadedSale.amountReceived = newAmountReceived;

    await isar.writeTxn(() async {
      await isar.sales.put(loadedSale);

      if (loadedSale.saleType == SaleType.credit &&
          loadedSale.customerUuid != null) {
        final customer = await isar.customers
            .filter()
            .uuidEqualTo(loadedSale.customerUuid!)
            .findFirst();

        if (customer != null) {
          customer.pendingDues -= delta;
          if (customer.pendingDues < 0) {
            customer.pendingDues = 0;
          }
          customer.updatedAt = DateTime.now();
          customer.isSynced = false;
          await isar.customers.put(customer);
        }
      }
    });
  }

  static Future<void> updateSalePaymentByUuid({
    required String saleUuid,
    required double newAmountReceived,
  }) async {
    await updateSalePayment(
      saleUuid: saleUuid,
      newAmountReceived: newAmountReceived,
    );
  }

  static Future<void> updateCustomerDues(int id, double newDue) async {
    final customer = await isar.customers.get(id);
    if (customer == null) {
      return;
    }
    customer.pendingDues = newDue;
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;
    await isar.writeTxn(() async {
      await isar.customers.put(customer);
    });
  }

  static Future<void> updateCustomerDuesByUuid(
    String customerUuid,
    double newDue,
  ) async {
    final customer =
        await isar.customers.filter().uuidEqualTo(customerUuid).findFirst();
    if (customer == null) {
      return;
    }

    customer.pendingDues = newDue;
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;

    await isar.writeTxn(() async {
      await isar.customers.put(customer);
    });
  }

  static Future<void> addSupplier(Supplier supplier) async {
    await isar.writeTxn(() async {
      await isar.suppliers.put(supplier);
    });
  }

  static Future<void> updateSupplier(Supplier supplier) async {
    supplier.updatedAt = DateTime.now();
    supplier.isSynced = false;
    supplier.version += 1;

    await isar.writeTxn(() async {
      await isar.suppliers.put(supplier);
    });
  }

  static Future<void> deleteSupplier(String supplierUuid) async {
    final supplier =
        await isar.suppliers.filter().uuidEqualTo(supplierUuid).findFirst();
    if (supplier == null) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.suppliers.delete(supplier.isarId);
    });
  }

  static Future<void> deleteSupplierByIsarId(int id) async {
    await isar.writeTxn(() async {
      await isar.suppliers.delete(id);
    });
  }

  static Future<List<Supplier>> getSuppliers() async {
    return isar.suppliers.filter().deletedEqualTo(false).findAll();
  }

  static Future<List<Supplier>> getAllSuppliers() async {
    return isar.suppliers
        .filter()
        .deletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<void> addPurchase(Purchase purchase) async {
    await isar.writeTxn(() async {
      await isar.purchases.put(purchase);

      for (final item in purchase.items) {
        final product = await isar.products
            .filter()
            .uuidEqualTo(item.productUuid)
            .findFirst();
        if (product != null) {
          product.quantity += item.quantity;
          product.updatedAt = DateTime.now();
          product.isSynced = false;
          await _putProductSafe(product);
        }
      }
    });
  }

  static Future<void> updatePurchase(Purchase purchase) async {
    purchase.updatedAt = DateTime.now();
    purchase.isSynced = false;
    await isar.writeTxn(() async {
      await isar.purchases.put(purchase);
    });
  }

  static Future<void> deletePurchase(int id) async {
    await isar.writeTxn(() async {
      await isar.purchases.delete(id);
    });
  }

  static Future<List<Purchase>> getAllPurchases() async {
    return isar.purchases.where().sortByDateDesc().findAll();
  }

  static Future<List<Purchase>> getPurchasesBySupplier(String supplierUuid) async {
    return isar.purchases
        .filter()
        .supplierUuidEqualTo(supplierUuid)
        .sortByDateDesc()
        .findAll();
  }

  static Future<void> addSupplierPayment(SupplierPayment payment) async {
    await isar.writeTxn(() async {
      await isar.supplierPayments.put(payment);
    });
  }

  static Future<List<SupplierPayment>> getSupplierPayments(
      String supplierUuid) async {
    return isar.supplierPayments
        .filter()
        .supplierUuidEqualTo(supplierUuid)
        .sortByDateDesc()
        .findAll();
  }

  static Future<List<SupplierPayment>> getAllSupplierPayments() async {
    return isar.supplierPayments.where().sortByDateDesc().findAll();
  }

  static Future<void> deleteInvalidSales() async {
    final sales = await isar.sales.where().findAll();
    await isar.writeTxn(() async {
      for (final sale in sales) {
        if (!sale.totalAmount.isFinite || sale.totalAmount.isNaN) {
          await isar.sales.delete(sale.isarId);
        }
      }
    });
  }

  static Future<double> getTotalSales() async {
    final sales = await isar.sales.where().findAll();
    double total = 0.0;
    for (final sale in sales) {
      if (sale.totalAmount.isFinite && !sale.totalAmount.isNaN) {
        total += sale.totalAmount;
      }
    }
    return total;
  }

  static Future<void> patchMissingAmountReceived() async {
    final sales = await isar.sales.where().findAll();
    await isar.writeTxn(() async {
      for (final sale in sales) {
        if (sale.amountReceived == 0) {
          sale.amountReceived =
              (sale.saleType == SaleType.cash) ? sale.totalAmount : 0;
          sale.updatedAt = DateTime.now();
          sale.isSynced = false;
          await isar.sales.put(sale);
        }
      }
    });
  }
}
