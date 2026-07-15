import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ssma/main.dart' show syncInitializer;

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
import 'package:ssma/models/peer_state.dart';

// ── Sync v2 models ──────────────────────────────────────────────────────────
import 'package:ssma/sync/v2/models/sync_change_log.dart';
import 'package:ssma/sync/v2/models/peer_device.dart';
import 'package:ssma/sync/v2/models/sync_cursor.dart';
import 'package:ssma/sync/v2/models/pairing_request.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;

class DBService {
  static Isar? _isarInstance;
  static const _uuid = Uuid();

  /// Appends a change record to BOTH the legacy ChangeLog (v1 LAN sync
  /// backward compatibility) AND the new SyncChangeLog (v2 engine).
  ///
  /// MUST be called from within an existing [isar.writeTxn] block.
  ///
  /// The entity UUID is auto-extracted from [payload]['id'] if [entityUuid]
  /// is not explicitly provided, so all existing call sites gain v2 support
  /// without modification.
  static Future<void> _appendChangeLog({
    required String collection,
    required String operationType,
    required Map<String, dynamic> payload,
    int recordId = 0,
    String? entityUuid,
    int entityVersion = 1,
  }) async {
    final deviceId = syncInitializer?.deviceId ?? syncV2?.deviceId ?? 'unknown';

    // Auto-extract entity UUID from the payload if not explicitly supplied.
    // All entity toJson() methods emit the UUID as the 'id' field.
    final resolvedUuid = entityUuid ?? payload['id'] as String?;

    // Map legacy 'upsert' operationType to v2 canonical operations.
    String v2Operation;
    if (operationType == 'DELETE') {
      v2Operation = 'DELETE';
    } else if (operationType == 'CREATE') {
      v2Operation = 'CREATE';
    } else if (operationType == 'UPDATE') {
      v2Operation = 'UPDATE';
    } else {
      // Legacy 'upsert': treat as CREATE if no existing record, UPDATE otherwise.
      // Since we can't know here without querying, default to UPDATE (safe — higher version wins).
      v2Operation = 'UPDATE';
    }

    // ── Legacy v1 ChangeLog ──────────────────────────────────────────────────
    final maxLog = await isar.changeLogs.where().sortByChangeSeqDesc().findFirst();
    final nextSeq = (maxLog?.changeSeq ?? 0) + 1;
    final log = ChangeLog()
      ..opId = _uuid.v4()
      ..changeSeq = nextSeq
      ..collection = collection
      ..recordId = recordId
      ..operationType = operationType
      ..payload = jsonEncode(payload)
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..synced = false
      ..originDeviceId = deviceId;
    await isar.changeLogs.put(log);

    // ── New v2 SyncChangeLog ─────────────────────────────────────────────────
    if (syncV2 != null && resolvedUuid != null) {
      await syncV2!.changeJournal.append(
        entityType: collection,
        entityId: resolvedUuid,
        operation: v2Operation,
        entityVersion: entityVersion,
        payload: payload,
      );
    }

  }


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

    // Fail startup if multiple Isar instances are detected before we open ours.
    if (Isar.instanceNames.isNotEmpty) {
      final names = Isar.instanceNames;
      debugPrint('Isar Architecture Audit [ERROR]: Multiple Isar instances detected: $names');
      throw StateError('Isar Architecture Audit Failed: Multiple Isar instances detected: $names');
    }

    final dir = await getApplicationDocumentsDirectory();
    _isarInstance = await Isar.open(
      [
        // ── Legacy business models (v1) ──────────────────────────
        CustomerSchema,
        ProductSchema,
        ItemSchema,
        ChangeLogSchema,
        SaleSchema,
        PurchaseSchema,
        CustomerPaymentSchema,
        SupplierSchema,
        SupplierPaymentSchema,
        PeerStateSchema,
        // ── Sync v2 models ──────────────────────────────────────
        SyncChangeLogSchema,
        PeerDeviceSchema,
        SyncCursorSchema,
        PairingRequestSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
    );

    // Fail startup if multiple Isar instances are detected after open
    if (Isar.instanceNames.length > 1) {
      final names = Isar.instanceNames;
      debugPrint('Isar Architecture Audit [ERROR]: Multiple Isar instances detected after open: $names');
      throw StateError('Isar Architecture Audit Failed: Multiple Isar instances detected after open: $names');
    }

    debugPrint('Isar Architecture Audit: Shared Isar instance initialized (hashCode=${_isarInstance.hashCode}, name=${_isarInstance?.name}, openInstances=${Isar.instanceNames})');
    
    // Run duplicate/stale peer cleanup migration
    await cleanupDuplicateAndStalePeers();
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
      await _appendChangeLog(
        collection: 'Product',
        operationType: 'CREATE',
        payload: product.toJson(),
        recordId: product.isarId,
        entityUuid: product.uuid,
        entityVersion: product.version,
      );
      debugPrint('[SYNC_OP]: v2 CREATE journal entry for product uuid=${product.uuid}');
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> updateProduct(Product product) async {
    product.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await _putProductSafe(product);
      await _appendChangeLog(
        collection: 'Product',
        operationType: 'UPDATE',
        payload: product.toJson(),
        recordId: product.isarId,
        entityUuid: product.uuid,
        entityVersion: product.version,
      );
      debugPrint('[SYNC_OP]: v2 UPDATE journal entry for product uuid=${product.uuid}');
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteProduct(String productUuid) async {
    final product =
        await isar.products.filter().uuidEqualTo(productUuid).findFirst();
    if (product == null) {
      return;
    }

    await isar.writeTxn(() async {
      product.deleted = true;
      product.updatedAt = DateTime.now();
      product.isSynced = false;
      product.version += 1;
      await _putProductSafe(product);
      await _appendChangeLog(
        collection: 'Product',
        operationType: 'DELETE',
        payload: product.toJson(),
        recordId: product.isarId,
        entityUuid: product.uuid,
        entityVersion: product.version,
      );
      debugPrint('[SYNC_OP]: v2 DELETE (soft) journal entry for product uuid=$productUuid');
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
    syncV2?.triggerDebouncedSync();
  }

  static Future<void> deleteProductByIsarId(int id) async {
    await isar.writeTxn(() async {
      final product = await isar.products.get(id);
      if (product != null) {
        product.deleted = true;
        product.updatedAt = DateTime.now();
        product.isSynced = false;
        await _putProductSafe(product);
        await _appendChangeLog(
          collection: 'Product',
          operationType: 'upsert',
          payload: product.toJson(),
          recordId: product.isarId,
        );
      }
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<Product?> getProductById(int id) async {
    return isar.products.get(id);
  }

  static Future<Product?> getProductByUuid(String uuid) async {
    return isar.products.filter().uuidEqualTo(uuid).findFirst();
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
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'upsert',
        payload: customer.toJson(),
        recordId: customer.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.customers.put(customer);
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'upsert',
        payload: customer.toJson(),
        recordId: customer.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'upsert',
        payload: customer.toJson(),
        recordId: customer.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<Customer?> getCustomerById(int id) async {
    return isar.customers.get(id);
  }

  static Future<void> addCustomerPayment(CustomerPayment payment) async {
    await isar.writeTxn(() async {
      await isar.customerPayments.put(payment);
      await _appendChangeLog(
        collection: 'CustomerPayment',
        operationType: 'upsert',
        payload: payment.toJson(),
        recordId: payment.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
        await _appendChangeLog(
          collection: 'Customer',
          operationType: 'upsert',
          payload: customer.toJson(),
          recordId: customer.isarId,
        );
      }

      // Soft-delete the payment instead of hard-deleting so peers can sync the deletion
      payment.deleted = true;
      payment.updatedAt = DateTime.now();
      payment.isSynced = false;
      payment.version += 1;
      await isar.customerPayments.put(payment);
      await _appendChangeLog(
        collection: 'CustomerPayment',
        operationType: 'upsert',
        payload: payment.toJson(),
        recordId: payment.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
              await _appendChangeLog(
                collection: 'Product',
                operationType: 'upsert',
                payload: product.toJson(),
                recordId: product.isarId,
              );
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
              await _appendChangeLog(
                collection: 'Customer',
                operationType: 'upsert',
                payload: customer.toJson(),
                recordId: customer.isarId,
              );
            }
          }

          // Soft-delete old sale entry instead of hard-delete
          oldSale.deleted = true;
          oldSale.updatedAt = DateTime.now();
          oldSale.isSynced = false;
          oldSale.version += 1;
          await isar.sales.put(oldSale);
          await _appendChangeLog(
            collection: 'Sale',
            operationType: 'upsert',
            payload: oldSale.toJson(),
            recordId: oldSale.isarId,
          );
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
          await _appendChangeLog(
            collection: 'Product',
            operationType: 'upsert',
            payload: product.toJson(),
            recordId: product.isarId,
          );
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
          await _appendChangeLog(
            collection: 'Customer',
            operationType: 'upsert',
            payload: customer.toJson(),
            recordId: customer.isarId,
          );
        }
      }

      await isar.sales.put(sale);
      await _appendChangeLog(
        collection: 'Sale',
        operationType: 'upsert',
        payload: sale.toJson(),
        recordId: sale.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<void> updateSale(Sale sale) async {
    sale.updatedAt = DateTime.now();
    sale.isSynced = false;
    await isar.writeTxn(() async {
      await isar.sales.put(sale);
      await _appendChangeLog(
        collection: 'Sale',
        operationType: 'upsert',
        payload: sale.toJson(),
        recordId: sale.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<Sale?> getSaleById(int id) async {
    return isar.sales.get(id);
  }

  static Future<void> deleteSale(int id) async {
    await isar.writeTxn(() async {
      final sale = await isar.sales.get(id);
      if (sale != null) {
        // Restore stock
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
            await _appendChangeLog(
              collection: 'Product',
              operationType: 'upsert',
              payload: product.toJson(),
              recordId: product.isarId,
            );
          }
        }

        // Restore dues
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
            await _appendChangeLog(
              collection: 'Customer',
              operationType: 'upsert',
              payload: customer.toJson(),
              recordId: customer.isarId,
            );
          }
        }

        sale.deleted = true;
        sale.updatedAt = DateTime.now();
        sale.isSynced = false;
        sale.version += 1;
        await isar.sales.put(sale);
        await _appendChangeLog(
          collection: 'Sale',
          operationType: 'upsert',
          payload: sale.toJson(),
          recordId: sale.isarId,
        );
      }
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
          await _appendChangeLog(
            collection: 'Product',
            operationType: 'upsert',
            payload: product.toJson(),
            recordId: product.isarId,
          );
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
          await _appendChangeLog(
            collection: 'Customer',
            operationType: 'upsert',
            payload: customer.toJson(),
            recordId: customer.isarId,
          );
        }
      }

      sale.deleted = true;
      sale.updatedAt = DateTime.now();
      sale.isSynced = false;
      sale.version += 1;
      await isar.sales.put(sale);
      await _appendChangeLog(
        collection: 'Sale',
        operationType: 'upsert',
        payload: sale.toJson(),
        recordId: sale.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
    loadedSale.updatedAt = DateTime.now();
    loadedSale.isSynced = false;

    await isar.writeTxn(() async {
      await isar.sales.put(loadedSale);
      // ✅ FIX: capture the Sale change so peers see the updated amountReceived
      await _appendChangeLog(
        collection: 'Sale',
        operationType: 'upsert',
        payload: loadedSale.toJson(),
        recordId: loadedSale.isarId,
      );

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
          await _appendChangeLog(
            collection: 'Customer',
            operationType: 'upsert',
            payload: customer.toJson(),
            recordId: customer.isarId,
          );
        }
      }
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'upsert',
        payload: customer.toJson(),
        recordId: customer.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
      await _appendChangeLog(
        collection: 'Customer',
        operationType: 'upsert',
        payload: customer.toJson(),
        recordId: customer.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<void> addSupplier(Supplier supplier) async {
    await isar.writeTxn(() async {
      await isar.suppliers.put(supplier);
      await _appendChangeLog(
        collection: 'Supplier',
        operationType: 'upsert',
        payload: supplier.toJson(),
        recordId: supplier.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<void> updateSupplier(Supplier supplier) async {
    supplier.updatedAt = DateTime.now();
    supplier.isSynced = false;
    supplier.version += 1;

    await isar.writeTxn(() async {
      await isar.suppliers.put(supplier);
      await _appendChangeLog(
        collection: 'Supplier',
        operationType: 'upsert',
        payload: supplier.toJson(),
        recordId: supplier.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<void> deleteSupplier(String supplierUuid) async {
    final supplier =
        await isar.suppliers.filter().uuidEqualTo(supplierUuid).findFirst();
    if (supplier == null) {
      return;
    }

    await isar.writeTxn(() async {
      supplier.deleted = true;
      supplier.updatedAt = DateTime.now();
      supplier.isSynced = false;
      supplier.version += 1;
      await isar.suppliers.put(supplier);
      await _appendChangeLog(
        collection: 'Supplier',
        operationType: 'upsert',
        payload: supplier.toJson(),
        recordId: supplier.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<void> deleteSupplierByIsarId(int id) async {
    await isar.writeTxn(() async {
      final supplier = await isar.suppliers.get(id);
      if (supplier != null) {
        supplier.deleted = true;
        supplier.updatedAt = DateTime.now();
        supplier.isSynced = false;
        supplier.version += 1;
        await isar.suppliers.put(supplier);
        await _appendChangeLog(
          collection: 'Supplier',
          operationType: 'upsert',
          payload: supplier.toJson(),
          recordId: supplier.isarId,
        );
      }
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
      await _appendChangeLog(
        collection: 'Purchase',
        operationType: 'upsert',
        payload: purchase.toJson(),
        recordId: purchase.isarId,
      );

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
          await _appendChangeLog(
            collection: 'Product',
            operationType: 'upsert',
            payload: product.toJson(),
            recordId: product.isarId,
          );
        }
      }
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<void> updatePurchase(Purchase purchase) async {
    purchase.updatedAt = DateTime.now();
    purchase.isSynced = false;
    await isar.writeTxn(() async {
      await isar.purchases.put(purchase);
      await _appendChangeLog(
        collection: 'Purchase',
        operationType: 'upsert',
        payload: purchase.toJson(),
        recordId: purchase.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
  }

  static Future<void> deletePurchase(int id) async {
    await isar.writeTxn(() async {
      final purchase = await isar.purchases.get(id);
      if (purchase != null) {
        purchase.deleted = true;
        purchase.updatedAt = DateTime.now();
        purchase.isSynced = false;
        purchase.version += 1;
        await isar.purchases.put(purchase);
        await _appendChangeLog(
          collection: 'Purchase',
          operationType: 'upsert',
          payload: purchase.toJson(),
          recordId: purchase.isarId,
        );
      }
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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
      await _appendChangeLog(
        collection: 'SupplierPayment',
        operationType: 'upsert',
        payload: payment.toJson(),
        recordId: payment.isarId,
      );
    });
    syncInitializer?.syncEngine.triggerDebouncedSync();
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

  static Future<void> cleanupDuplicateAndStalePeers() async {
    debugPrint('DBService [CLEANUP]: Starting peer cleanup and migration (isarHash=${isar.hashCode})...');
    try {
      final peers = await isar.peerStates.where().findAll();
      final Map<String, PeerState> uniquePeersByIp = {};
      final List<int> idsToDelete = [];

      // Sort peers by lastSeen descending so we keep the most recently seen one
      final sortedPeers = List<PeerState>.from(peers);
      sortedPeers.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

      for (final peer in sortedPeers) {
        if (uniquePeersByIp.containsKey(peer.peerIp)) {
          // This is a duplicate peer with the same IP but a different peerId (likely from a previous app start with a different transient device ID)
          idsToDelete.add(peer.id);
          debugPrint('DBService [CLEANUP]: Found duplicate peer record to delete: id=${peer.id}, peerId=${peer.peerId}, ip=${peer.peerIp}');
        } else {
          uniquePeersByIp[peer.peerIp] = peer;
        }
      }

      // ✅ FIX: Use 30-day threshold (matching compaction retention) instead of 24h.
      // Deleting peers after 24h on every app restart wipes their lastPulledChangeSeq,
      // forcing a full re-sync every time a device is offline for more than a day.
      final cutoff = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
      for (final peer in sortedPeers) {
        if (peer.lastSeen < cutoff && !idsToDelete.contains(peer.id)) {
          idsToDelete.add(peer.id);
          debugPrint('DBService [CLEANUP]: Found stale peer record to delete (last seen > 30d ago): id=${peer.id}, peerId=${peer.peerId}, ip=${peer.peerIp}');
        }
      }

      if (idsToDelete.isNotEmpty) {
        await isar.writeTxn(() async {
          await isar.peerStates.deleteAll(idsToDelete);
        });
        debugPrint('DBService [CLEANUP]: Successfully deleted ${idsToDelete.length} stale/duplicate peer records (isarHash=${isar.hashCode})');
      } else {
        debugPrint('DBService [CLEANUP]: No stale/duplicate peer records found to clean up');
      }
    } catch (e, st) {
      debugPrint('DBService [CLEANUP]: ❌ Failed to run peer cleanup migration: $e\n$st');
    }
  }
}
