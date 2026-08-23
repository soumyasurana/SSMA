import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/godown_item.dart';
import 'package:ssma/models/godown_movement.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/report_models.dart';
import 'package:ssma/utils/sale_metadata.dart';

class ReportService {
  static DateTimeRange getPresetRange(ReportTimePreset preset) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (preset) {
      case ReportTimePreset.today:
        return DateTimeRange(start: todayStart, end: todayEnd);

      case ReportTimePreset.yesterday:
        final yStart = todayStart.subtract(const Duration(days: 1));
        final yEnd =
            DateTime(yStart.year, yStart.month, yStart.day, 23, 59, 59, 999);
        return DateTimeRange(start: yStart, end: yEnd);

      case ReportTimePreset.thisWeek:
        final weekday = now.weekday; // 1 = Mon, 7 = Sun
        final weekStart = todayStart.subtract(Duration(days: weekday - 1));
        return DateTimeRange(start: weekStart, end: todayEnd);

      case ReportTimePreset.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        return DateTimeRange(
            start: monthStart,
            end: monthEnd.isAfter(todayEnd) ? todayEnd : monthEnd);

      case ReportTimePreset.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        return DateTimeRange(start: lastMonthStart, end: lastMonthEnd);

      case ReportTimePreset.thisQuarter:
        final currentQuarter = ((now.month - 1) / 3).floor();
        final quarterStart = DateTime(now.year, currentQuarter * 3 + 1, 1);
        return DateTimeRange(start: quarterStart, end: todayEnd);

      case ReportTimePreset.financialYear:
        // Indian FY: April 1 to March 31
        final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
        final fyStart = DateTime(fyStartYear, 4, 1);
        return DateTimeRange(start: fyStart, end: todayEnd);

      case ReportTimePreset.allTime:
        final allStart = DateTime(2020, 1, 1);
        return DateTimeRange(start: allStart, end: todayEnd);

      case ReportTimePreset.custom:
        final customStart = todayStart.subtract(const Duration(days: 30));
        return DateTimeRange(start: customStart, end: todayEnd);
    }
  }

  static String getPresetLabel(ReportTimePreset preset) {
    switch (preset) {
      case ReportTimePreset.today:
        return 'Today';
      case ReportTimePreset.yesterday:
        return 'Yesterday';
      case ReportTimePreset.thisWeek:
        return 'This Week';
      case ReportTimePreset.thisMonth:
        return 'This Month';
      case ReportTimePreset.lastMonth:
        return 'Last Month';
      case ReportTimePreset.thisQuarter:
        return 'This Quarter';
      case ReportTimePreset.financialYear:
        return 'Financial Year (FY)';
      case ReportTimePreset.allTime:
        return 'All Time';
      case ReportTimePreset.custom:
        return 'Custom Date Range';
    }
  }

  static Future<BusinessReportData> generateReport({
    required DateTime startDate,
    required DateTime endDate,
    required String presetLabel,
  }) async {
    final isar = DBService.isar;

    // 1. Fetch Sales in Date Range
    final sales = await isar.sales
        .filter()
        .deletedEqualTo(false)
        .and()
        .dateBetween(startDate, endDate)
        .sortByDateDesc()
        .findAll();

    // 2. Fetch Purchases in Date Range
    final purchases = await isar.purchases
        .filter()
        .deletedEqualTo(false)
        .and()
        .dateBetween(startDate, endDate)
        .sortByDateDesc()
        .findAll();

    // 3. Fetch Customer Payments in Date Range
    final customerPayments = await isar.customerPayments
        .filter()
        .deletedEqualTo(false)
        .and()
        .dateBetween(startDate, endDate)
        .sortByDateDesc()
        .findAll();

    // 4. Fetch Supplier Payments in Date Range
    final supplierPayments = await isar.supplierPayments
        .filter()
        .deletedEqualTo(false)
        .and()
        .dateBetween(startDate, endDate)
        .sortByDateDesc()
        .findAll();

    // 5. Fetch Global Business Entities
    final allProducts =
        await isar.products.filter().deletedEqualTo(false).findAll();
    final allCustomers = await DBService.getCustomers();
    final allSuppliers =
        await isar.suppliers.filter().deletedEqualTo(false).findAll();
    final allPurchases =
        await isar.purchases.filter().deletedEqualTo(false).findAll();
    final allSupplierPayments =
        await isar.supplierPayments.filter().deletedEqualTo(false).findAll();
    final allGodownItems =
        await isar.godownItems.filter().deletedEqualTo(false).findAll();
    final allMovements = await isar.godownMovements.where().findAll();

    final productMap = {for (final p in allProducts) p.uuid: p};

    // ─── P&L Calculations ──────────────────────────────────────────────────
    double grossSales = 0.0;
    double cogs = 0.0;
    int totalItemsSold = 0;
    double salesCashCollected = 0.0;
    double cashSalesTotal = 0.0;
    double creditSalesTotal = 0.0;
    double periodCustomerReceivablesAdded = 0.0;

    final Map<String, _ProductAggregator> productStats = {};
    final Map<String, _CustomerAggregator> customerStats = {};
    final Map<String, _PaymentMethodAggregator> paymentMethodAggregators = {};

    for (final sale in sales) {
      grossSales += sale.totalAmount;
      salesCashCollected += sale.amountReceived;

      if (sale.saleType == SaleType.cash) {
        cashSalesTotal += sale.totalAmount;
      } else {
        creditSalesTotal += sale.totalAmount;
        final unpaidPart = sale.totalAmount - sale.amountReceived;
        if (unpaidPart > 0) {
          periodCustomerReceivablesAdded += unpaidPart;
        }
      }

      // Track Customer Activity
      final cKey = sale.customerUuid ?? sale.buyerName ?? 'Walk-in Customer';
      customerStats.putIfAbsent(
        cKey,
        () => _CustomerAggregator(
          customerUuid: sale.customerUuid ?? '',
          name: (sale.buyerName != null && sale.buyerName!.isNotEmpty)
              ? sale.buyerName!
              : 'Walk-in Customer',
          phone: sale.buyerContact,
        ),
      );
      customerStats[cKey]!.orderCount++;
      customerStats[cKey]!.totalBilled += sale.totalAmount;
      customerStats[cKey]!.totalPaid += sale.amountReceived;

      // Track Items & COGS
      double saleCost = 0.0;
      for (final item in sale.items) {
        totalItemsSold += item.quantity;
        final fallbackProduct = productMap[item.productUuid];
        final costPerUnit = item.purchasePrice > 0
            ? item.purchasePrice
            : (fallbackProduct?.purchasePrice ?? 0.0);
        final itemTotalCost = costPerUnit * item.quantity;
        final itemRevenue = item.unitPrice * item.quantity;
        final itemProfit = itemRevenue - itemTotalCost;

        saleCost += itemTotalCost;

        final pKey =
            item.productUuid.isNotEmpty ? item.productUuid : item.productName;
        productStats.putIfAbsent(
          pKey,
          () => _ProductAggregator(
            productUuid: item.productUuid,
            name: item.productName,
            currentStock: fallbackProduct?.quantity ?? 0,
          ),
        );
        productStats[pKey]!.quantitySold += item.quantity;
        productStats[pKey]!.revenue += itemRevenue;
        productStats[pKey]!.totalCost += itemTotalCost;
        productStats[pKey]!.profit += itemProfit;
      }
      cogs += saleCost;

      // Track Payment Methods
      final meta = SaleMetadata.parse(sale.comment);
      if (meta.payments.isNotEmpty) {
        for (final p in meta.payments) {
          final mName = p.method.trim().isEmpty ? 'Cash' : p.method.trim();
          paymentMethodAggregators.putIfAbsent(
              mName, () => _PaymentMethodAggregator(mName));
          paymentMethodAggregators[mName]!.amount += p.amount;
          paymentMethodAggregators[mName]!.count++;
        }
      } else if (sale.amountReceived > 0) {
        final mName = sale.saleType == SaleType.cash ? 'Cash' : 'Receipt';
        paymentMethodAggregators.putIfAbsent(
            mName, () => _PaymentMethodAggregator(mName));
        paymentMethodAggregators[mName]!.amount += sale.amountReceived;
        paymentMethodAggregators[mName]!.count++;
      }
    }

    final grossProfit = grossSales - cogs;
    final profitMarginPercentage =
        grossSales > 0 ? (grossProfit / grossSales) * 100 : 0.0;
    final totalOrders = sales.length;
    final averageOrderValue = totalOrders > 0 ? grossSales / totalOrders : 0.0;

    final cashSalesRatio =
        grossSales > 0 ? (cashSalesTotal / grossSales) * 100 : 0.0;
    final creditSalesRatio =
        grossSales > 0 ? (creditSalesTotal / grossSales) * 100 : 0.0;

    // ─── Cash Flow & Payments ──────────────────────────────────────────────
    final customerReceiptsCollected =
        customerPayments.fold(0.0, (sum, p) => sum + p.amountReceived);
    final totalCashInflow = salesCashCollected + customerReceiptsCollected;

    double purchaseCashPaid = 0.0;
    double periodSupplierPayablesAdded = 0.0;
    for (final p in purchases) {
      // In purchases, full amount is purchase cost; track any paid
      purchaseCashPaid += p.totalAmount;
    }

    final supplierPaymentsPaid =
        supplierPayments.fold(0.0, (sum, p) => sum + p.amount);
    final totalCashOutflow = supplierPaymentsPaid;
    final netCashFlow = totalCashInflow - totalCashOutflow;

    // Build Payment Method Stats List
    final totalPaymentsReceived =
        paymentMethodAggregators.values.fold(0.0, (sum, pm) => sum + pm.amount);
    final paymentMethods = paymentMethodAggregators.values.map((pm) {
      final percentage = totalPaymentsReceived > 0
          ? (pm.amount / totalPaymentsReceived) * 100
          : 0.0;
      return PaymentMethodStat(
        method: pm.name,
        amount: pm.amount,
        percentage: percentage,
        transactionCount: pm.count,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // ─── Customer Receivables ──────────────────────────────────────────────
    // Customer balances are cached fields, so fetch them via DBService to
    // force reconciliation from active Sale and CustomerPayment records first.
    double totalCustomerReceivables = 0.0;
    final List<CustomerReportItem> allCustomerReports = [];
    for (final customer in allCustomers) {
      final currentDue = customer.pendingDues;
      if (currentDue > 0) {
        totalCustomerReceivables += currentDue;
      }
      final agg = customerStats[customer.uuid] ?? customerStats[customer.name];
      allCustomerReports.add(CustomerReportItem(
        customerUuid: customer.uuid,
        customerName: customer.name,
        phone: customer.phone,
        orderCount: agg?.orderCount ?? 0,
        totalBilled: agg?.totalBilled ?? 0.0,
        totalPaid: agg?.totalPaid ?? 0.0,
        currentOutstanding: currentDue,
      ));
    }

    final topCustomersByRevenue =
        List<CustomerReportItem>.from(allCustomerReports)
          ..sort((a, b) => b.totalBilled.compareTo(a.totalBilled));
    final topCustomersByOutstanding = List<CustomerReportItem>.from(
        allCustomerReports)
      ..sort((a, b) => b.currentOutstanding.compareTo(a.currentOutstanding));

    // ─── Supplier Payables ─────────────────────────────────────────────────
    final Map<String, double> supplierAllPurchasesMap = {};
    final Map<String, double> supplierAllPaymentsMap = {};
    final Map<String, int> supplierPeriodPurchasesCount = {};
    final Map<String, double> supplierPeriodPurchasesTotal = {};
    final Map<String, double> supplierPeriodPaymentsTotal = {};

    for (final p in allPurchases) {
      supplierAllPurchasesMap[p.supplierUuid] =
          (supplierAllPurchasesMap[p.supplierUuid] ?? 0.0) + p.totalAmount;
    }
    for (final pm in allSupplierPayments) {
      supplierAllPaymentsMap[pm.supplierUuid] =
          (supplierAllPaymentsMap[pm.supplierUuid] ?? 0.0) + pm.amount;
    }

    for (final p in purchases) {
      supplierPeriodPurchasesCount[p.supplierUuid] =
          (supplierPeriodPurchasesCount[p.supplierUuid] ?? 0) + 1;
      supplierPeriodPurchasesTotal[p.supplierUuid] =
          (supplierPeriodPurchasesTotal[p.supplierUuid] ?? 0.0) + p.totalAmount;
    }
    for (final pm in supplierPayments) {
      supplierPeriodPaymentsTotal[pm.supplierUuid] =
          (supplierPeriodPaymentsTotal[pm.supplierUuid] ?? 0.0) + pm.amount;
    }

    double totalSupplierPayables = 0.0;
    final List<SupplierReportItem> allSupplierReports = [];
    for (final supplier in allSuppliers) {
      final totalP = supplierAllPurchasesMap[supplier.uuid] ?? 0.0;
      final totalPm = supplierAllPaymentsMap[supplier.uuid] ?? 0.0;
      final balanceDue = (totalP - totalPm).clamp(0.0, double.infinity);
      totalSupplierPayables += balanceDue;

      allSupplierReports.add(SupplierReportItem(
        supplierUuid: supplier.uuid,
        supplierName: supplier.name,
        phone: supplier.contact,
        purchaseCount: supplierPeriodPurchasesCount[supplier.uuid] ?? 0,
        totalPurchased: supplierPeriodPurchasesTotal[supplier.uuid] ?? 0.0,
        totalPaid: supplierPeriodPaymentsTotal[supplier.uuid] ?? 0.0,
        currentBalanceDue: balanceDue,
      ));
    }

    final topSuppliersByPurchases =
        List<SupplierReportItem>.from(allSupplierReports)
          ..sort((a, b) => b.totalPurchased.compareTo(a.totalPurchased));
    final topSuppliersByOutstanding =
        List<SupplierReportItem>.from(allSupplierReports)
          ..sort((a, b) => b.currentBalanceDue.compareTo(a.currentBalanceDue));

    final netWorkingCapitalPosition =
        totalCustomerReceivables - totalSupplierPayables;

    // ─── Inventory & Godown Valuation ──────────────────────────────────────
    int totalShopStockUnits = 0;
    double shopInventoryValuationAtCost = 0.0;
    double shopInventoryValuationAtRetail = 0.0;
    int lowStockCount = 0;
    int outOfStockCount = 0;

    for (final p in allProducts) {
      totalShopStockUnits += p.quantity;
      shopInventoryValuationAtCost += (p.quantity * p.purchasePrice);
      shopInventoryValuationAtRetail += (p.quantity * p.salePrice);
      if (p.quantity <= 0) {
        outOfStockCount++;
      } else if (p.quantity <= 5) {
        lowStockCount++;
      }
    }
    final potentialInventoryProfit =
        shopInventoryValuationAtRetail - shopInventoryValuationAtCost;

    int totalGodownStockUnits = 0;
    double godownInventoryValuationAtCost = 0.0;
    for (final gi in allGodownItems) {
      totalGodownStockUnits += gi.quantity;
      godownInventoryValuationAtCost += (gi.quantity * gi.unitCost);
    }

    final periodMovements = allMovements.where((m) =>
        !m.createdAt.isBefore(startDate) && !m.createdAt.isAfter(endDate));
    final totalGodownMovementsInPeriod = periodMovements.length;
    int godownTransfersToShopUnits = 0;
    for (final m in periodMovements) {
      if (m.movementType == GodownMovementType.transferToShop) {
        godownTransfersToShopUnits += m.quantityChanged.abs();
      }
    }

    // ─── Product Rankings ──────────────────────────────────────────────────
    final List<ProductReportItem> productReportList =
        productStats.values.map((p) {
      final margin = p.revenue > 0 ? (p.profit / p.revenue) * 100 : 0.0;
      return ProductReportItem(
        productUuid: p.productUuid,
        productName: p.name,
        quantitySold: p.quantitySold,
        revenue: p.revenue,
        totalCost: p.totalCost,
        profit: p.profit,
        marginPercentage: margin,
        currentStock: p.currentStock,
      );
    }).toList();

    final topProductsByRevenue = List<ProductReportItem>.from(productReportList)
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    final topProductsByProfit = List<ProductReportItem>.from(productReportList)
      ..sort((a, b) => b.profit.compareTo(a.profit));
    final topProductsByQuantity =
        List<ProductReportItem>.from(productReportList)
          ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    // Dead / slow products in inventory with 0 sales in period
    final activeProductUuids = productStats.keys.toSet();
    final List<ProductReportItem> deadOrLowMovingProducts = [];
    for (final p in allProducts) {
      if (!activeProductUuids.contains(p.uuid) &&
          !activeProductUuids.contains(p.name)) {
        deadOrLowMovingProducts.add(ProductReportItem(
          productUuid: p.uuid,
          productName: p.name,
          quantitySold: 0,
          revenue: 0.0,
          totalCost: 0.0,
          profit: 0.0,
          marginPercentage: 0.0,
          currentStock: p.quantity,
        ));
      }
    }
    deadOrLowMovingProducts
        .sort((a, b) => b.currentStock.compareTo(a.currentStock));

    return BusinessReportData(
      startDate: startDate,
      endDate: endDate,
      presetLabel: presetLabel,
      grossSales: grossSales,
      totalDiscountsOrCharges: 0.0,
      netSales: grossSales,
      cogs: cogs,
      grossProfit: grossProfit,
      profitMarginPercentage: profitMarginPercentage,
      totalOrders: totalOrders,
      averageOrderValue: averageOrderValue,
      totalItemsSold: totalItemsSold,
      salesCashCollected: salesCashCollected,
      customerReceiptsCollected: customerReceiptsCollected,
      totalCashInflow: totalCashInflow,
      purchaseCashPaid: purchaseCashPaid,
      supplierPaymentsPaid: supplierPaymentsPaid,
      totalCashOutflow: totalCashOutflow,
      netCashFlow: netCashFlow,
      paymentMethods: paymentMethods,
      cashSalesTotal: cashSalesTotal,
      creditSalesTotal: creditSalesTotal,
      cashSalesRatio: cashSalesRatio,
      creditSalesRatio: creditSalesRatio,
      totalCustomerReceivables: totalCustomerReceivables,
      periodCustomerReceivablesAdded: periodCustomerReceivablesAdded,
      totalSupplierPayables: totalSupplierPayables,
      periodSupplierPayablesAdded: periodSupplierPayablesAdded,
      netWorkingCapitalPosition: netWorkingCapitalPosition,
      totalShopProductTypes: allProducts.length,
      totalShopStockUnits: totalShopStockUnits,
      shopInventoryValuationAtCost: shopInventoryValuationAtCost,
      shopInventoryValuationAtRetail: shopInventoryValuationAtRetail,
      potentialInventoryProfit: potentialInventoryProfit,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      totalGodownItemTypes: allGodownItems.length,
      totalGodownStockUnits: totalGodownStockUnits,
      godownInventoryValuationAtCost: godownInventoryValuationAtCost,
      totalGodownMovementsInPeriod: totalGodownMovementsInPeriod,
      godownTransfersToShopUnits: godownTransfersToShopUnits,
      topProductsByRevenue: topProductsByRevenue,
      topProductsByProfit: topProductsByProfit,
      topProductsByQuantity: topProductsByQuantity,
      deadOrLowMovingProducts: deadOrLowMovingProducts,
      topCustomersByRevenue: topCustomersByRevenue,
      topCustomersByOutstanding: topCustomersByOutstanding,
      topSuppliersByPurchases: topSuppliersByPurchases,
      topSuppliersByOutstanding: topSuppliersByOutstanding,
    );
  }
}

class _ProductAggregator {
  final String productUuid;
  final String name;
  final int currentStock;
  int quantitySold = 0;
  double revenue = 0.0;
  double totalCost = 0.0;
  double profit = 0.0;

  _ProductAggregator({
    required this.productUuid,
    required this.name,
    required this.currentStock,
  });
}

class _CustomerAggregator {
  final String customerUuid;
  final String name;
  final String? phone;
  int orderCount = 0;
  double totalBilled = 0.0;
  double totalPaid = 0.0;

  _CustomerAggregator({
    required this.customerUuid,
    required this.name,
    this.phone,
  });
}

class _PaymentMethodAggregator {
  final String name;
  double amount = 0.0;
  int count = 0;

  _PaymentMethodAggregator(this.name);
}
