import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/utils/sale_metadata.dart';
import 'package:intl/intl.dart';

import 'dashboard_models.dart';

class DashboardService {
  static Future<DashboardData> getDashboardData({
    required DashboardDateRange range,
    DateTimeRange? customRange,
  }) async {
    final now = DateTime.now();

    // 1. Calculate date boundaries
    late DateTime startDate;
    late DateTime endDate;
    late DateTime prevStartDate;
    late DateTime prevEndDate;

    switch (range) {
      case DashboardDateRange.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        prevStartDate = startDate.subtract(const Duration(days: 1));
        prevEndDate = endDate.subtract(const Duration(days: 1));
        break;
      case DashboardDateRange.thisWeek:
        final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: currentWeekday - 1));
        endDate = startDate
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
        prevStartDate = startDate.subtract(const Duration(days: 7));
        prevEndDate = endDate.subtract(const Duration(days: 7));
        break;
      case DashboardDateRange.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(milliseconds: 1));
        prevStartDate = DateTime(now.year, now.month - 1, 1);
        prevEndDate = startDate.subtract(const Duration(milliseconds: 1));
        break;
      case DashboardDateRange.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        prevStartDate = DateTime(now.year - 1, 1, 1);
        prevEndDate = DateTime(now.year - 1, 12, 31, 23, 59, 59, 999);
        break;
      case DashboardDateRange.custom:
        if (customRange != null) {
          startDate = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
          endDate = DateTime(customRange.end.year, customRange.end.month, customRange.end.day, 23, 59, 59, 999);
        } else {
          startDate = now.subtract(const Duration(days: 30));
          endDate = now;
        }
        final diff = endDate.difference(startDate);
        prevStartDate = startDate.subtract(diff);
        prevEndDate = startDate.subtract(const Duration(milliseconds: 1));
        break;
    }

    final isar = DBService.isar;

    // 2. Fetch current and previous sales/purchases matching the date ranges
    final currentSales = await isar.sales
        .filter()
        .deletedEqualTo(false)
        .and()
        .dateBetween(startDate, endDate)
        .sortByDateDesc()
        .findAll();

    final prevSales = await isar.sales
        .filter()
        .deletedEqualTo(false)
        .and()
        .dateBetween(prevStartDate, prevEndDate)
        .findAll();

    final currentPurchases = await isar.purchases
        .filter()
        .deletedEqualTo(false)
        .and()
        .dateBetween(startDate, endDate)
        .sortByDateDesc()
        .findAll();

    final prevPurchases = await isar.purchases
        .filter()
        .deletedEqualTo(false)
        .and()
        .dateBetween(prevStartDate, prevEndDate)
        .findAll();

    // 3. Fetch independent metrics (customers, products, suppliers)
    final allProducts = await isar.products.filter().deletedEqualTo(false).findAll();
    final allProductsIncludingDeleted = await isar.products.where().findAll();
    final allCustomers = await isar.customers.filter().deletedEqualTo(false).findAll();
    final allSuppliers = await isar.suppliers.filter().deletedEqualTo(false).findAll();

    // 4. Compute Receivables
    double receivablesTotal = 0.0;
    int receivablesCustomerCount = 0;
    final List<OutstandingCustomerData> customerOutstandings = [];

    for (final customer in allCustomers) {
      if (customer.pendingDues > 0) {
        receivablesTotal += customer.pendingDues;
        receivablesCustomerCount++;
        customerOutstandings.add(OutstandingCustomerData(
          customerUuid: customer.uuid,
          customerName: customer.name,
          outstandingAmount: customer.pendingDues,
        ));
      }
    }
    // Sort customer outstandings descending
    customerOutstandings.sort((a, b) => b.outstandingAmount.compareTo(a.outstandingAmount));
    final topReceivables = customerOutstandings.take(5).toList();

    // 5. Compute Payables
    // Balance per supplier = sum(purchases) - sum(payments)
    final allPurchasesList = await isar.purchases.filter().deletedEqualTo(false).findAll();
    final allSupplierPayments = await isar.supplierPayments.filter().deletedEqualTo(false).findAll();

    final Map<String, double> supplierPurchasesSum = {};
    final Map<String, double> supplierPaymentsSum = {};

    for (final p in allPurchasesList) {
      supplierPurchasesSum[p.supplierUuid] = (supplierPurchasesSum[p.supplierUuid] ?? 0.0) + p.totalAmount;
    }
    for (final pm in allSupplierPayments) {
      supplierPaymentsSum[pm.supplierUuid] = (supplierPaymentsSum[pm.supplierUuid] ?? 0.0) + pm.amount;
    }

    double payablesTotal = 0.0;
    int payablesSupplierCount = 0;
    final List<OutstandingSupplierData> supplierOutstandings = [];

    final supplierMap = {for (var s in allSuppliers) s.uuid: s};

    for (final supplierUuid in supplierMap.keys) {
      final totalBought = supplierPurchasesSum[supplierUuid] ?? 0.0;
      final totalPaid = supplierPaymentsSum[supplierUuid] ?? 0.0;
      final balance = totalBought - totalPaid;

      if (balance > 0) {
        payablesTotal += balance;
        payablesSupplierCount++;
        supplierOutstandings.add(OutstandingSupplierData(
          supplierUuid: supplierUuid,
          supplierName: supplierMap[supplierUuid]?.name ?? 'Unknown Supplier',
          outstandingAmount: balance,
        ));
      }
    }
    supplierOutstandings.sort((a, b) => b.outstandingAmount.compareTo(a.outstandingAmount));
    final topPayables = supplierOutstandings.take(5).toList();

    // 6. Compute Inventory Overview
    int totalInventoryItems = allProducts.length;
    int totalInventoryQuantity = 0;
    double estimatedInventoryValue = 0.0;
    int lowStockItemCount = 0;
    int outOfStockItemCount = 0;
    final List<LowStockProductData> lowStockProducts = [];

    for (final product in allProducts) {
      totalInventoryQuantity += product.quantity;
      estimatedInventoryValue += (product.purchasePrice * product.quantity);
      if (product.quantity == 0) {
        outOfStockItemCount++;
      }
      if (product.quantity < 5) {
        lowStockItemCount++;
        lowStockProducts.add(LowStockProductData(
          productName: product.name,
          currentQuantity: product.quantity,
          sellingPrice: product.salePrice,
        ));
      }
    }
    lowStockProducts.sort((a, b) => a.currentQuantity.compareTo(b.currentQuantity));

    // 7. Process sales in current range
    double totalSales = 0.0;
    int salesCount = currentSales.length;
    double totalCost = 0.0;
    double grossProfit = 0.0;

    double cashReceived = 0.0;
    double upiReceived = 0.0;
    final Map<String, double> paymentMethodsSum = {};

    final Map<String, int> topProductsQty = {};
    final Map<String, double> topProductsRevenue = {};
    final Map<String, double> topProductsProfit = {};

    int unusualZeroProfitSales = 0;

    for (final sale in currentSales) {
      totalSales += sale.totalAmount;

      // Profit calculations
      double saleCost = 0.0;
      for (final item in sale.items) {
        // Fallback to product model purchase price if item purchasePrice is zero
        double costPrice = item.purchasePrice;
        if (costPrice == 0.0) {
          final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
          costPrice = prod.purchasePrice;
        }

        saleCost += (costPrice * item.quantity);

        // Top product performance analytics
        topProductsQty[item.productName] = (topProductsQty[item.productName] ?? 0) + item.quantity;
        topProductsRevenue[item.productName] = (topProductsRevenue[item.productName] ?? 0.0) + item.total;
        
        final itemProfit = item.total - (costPrice * item.quantity);
        topProductsProfit[item.productName] = (topProductsProfit[item.productName] ?? 0.0) + itemProfit;
      }
      totalCost += saleCost;
      final saleProfit = sale.totalAmount - saleCost;
      if (sale.totalAmount > 0 && saleProfit <= 0) {
        unusualZeroProfitSales++;
      }

      // Payment breakdowns
      final meta = SaleMetadata.parse(sale.comment);
      if (meta.payments.isNotEmpty) {
        for (final p in meta.payments) {
          final methodNormalized = p.method.toLowerCase().trim();
          paymentMethodsSum[methodNormalized] = (paymentMethodsSum[methodNormalized] ?? 0.0) + p.amount;
        }
      } else {
        // Fallback to saleType
        if (sale.amountReceived > 0) {
          const methodNormalized = 'cash';
          paymentMethodsSum[methodNormalized] = (paymentMethodsSum[methodNormalized] ?? 0.0) + sale.amountReceived;
        }
      }
    }

    grossProfit = totalSales - totalCost;
    final profitMargin = totalSales > 0 ? (grossProfit / totalSales) * 100 : 0.0;
    final averageBillValue = salesCount > 0 ? totalSales / salesCount : 0.0;

    double totalPurchases = currentPurchases.fold(0.0, (sum, p) => sum + p.totalAmount);
    int purchasesCount = currentPurchases.length;

    // Normalizing payment methods to UI names
    cashReceived = paymentMethodsSum['cash'] ?? 0.0;
    final upiReceivedSum = paymentMethodsSum['upi'] ?? 0.0;
    final upiDigitalSum = upiReceivedSum + (paymentMethodsSum['digital'] ?? 0.0) + (paymentMethodsSum['card'] ?? 0.0);
    final bankReceivedSum = paymentMethodsSum['bank'] ?? 0.0;
    
    // Remaining other payment methods
    double otherReceivedSum = 0.0;
    paymentMethodsSum.forEach((key, val) {
      if (key != 'cash' && key != 'upi' && key != 'digital' && key != 'card' && key != 'bank') {
        otherReceivedSum += val;
      }
    });

    final double totalCollections = cashReceived + upiDigitalSum + bankReceivedSum + otherReceivedSum;
    final List<PaymentMethodBreakdown> paymentBreakdown = [];
    if (totalCollections > 0) {
      paymentBreakdown.add(PaymentMethodBreakdown(
        method: 'Cash',
        amount: cashReceived,
        percentage: (cashReceived / totalCollections) * 100,
      ));
      paymentBreakdown.add(PaymentMethodBreakdown(
        method: 'UPI / Digital',
        amount: upiDigitalSum,
        percentage: (upiDigitalSum / totalCollections) * 100,
      ));
      paymentBreakdown.add(PaymentMethodBreakdown(
        method: 'Bank Transfer',
        amount: bankReceivedSum,
        percentage: (bankReceivedSum / totalCollections) * 100,
      ));
      if (otherReceivedSum > 0) {
        paymentBreakdown.add(PaymentMethodBreakdown(
          method: 'Other',
          amount: otherReceivedSum,
          percentage: (otherReceivedSum / totalCollections) * 100,
        ));
      }
    } else {
      // Empty payment breakdown defaults
      paymentBreakdown.add(PaymentMethodBreakdown(method: 'Cash', amount: 0, percentage: 0));
      paymentBreakdown.add(PaymentMethodBreakdown(method: 'UPI / Digital', amount: 0, percentage: 0));
      paymentBreakdown.add(PaymentMethodBreakdown(method: 'Bank Transfer', amount: 0, percentage: 0));
    }

    // 8. Top products ranking
    final List<TopProductData> topProducts = [];
    for (final productName in topProductsQty.keys) {
      topProducts.add(TopProductData(
        productName: productName,
        quantitySold: topProductsQty[productName] ?? 0,
        revenue: topProductsRevenue[productName] ?? 0.0,
        profit: topProductsProfit[productName] ?? 0.0,
      ));
    }

    // 9. Chart buckets formatting based on granularity
    final List<DashboardChartPoint> salesTrend = [];
    final List<DashboardChartPoint> profitTrend = [];

    // Format granularity buckets
    if (range == DashboardDateRange.today) {
      // 24 hours buckets
      final Map<int, double> hourSales = {};
      final Map<int, double> hourProfit = {};
      for (final sale in currentSales) {
        final hr = sale.date.hour;
        hourSales[hr] = (hourSales[hr] ?? 0.0) + sale.totalAmount;

        double saleCost = 0.0;
        for (final item in sale.items) {
          double costPrice = item.purchasePrice;
          if (costPrice == 0.0) {
            final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
            costPrice = prod.purchasePrice;
          }
          saleCost += (costPrice * item.quantity);
        }
        hourProfit[hr] = (hourProfit[hr] ?? 0.0) + (sale.totalAmount - saleCost);
      }

      for (int h = 0; h < 24; h += 2) {
        final hrText = h == 0
            ? '12 AM'
            : h < 12
                ? '$h AM'
                : h == 12
                    ? '12 PM'
                    : '${h - 12} PM';
        final val = (hourSales[h] ?? 0.0) + (hourSales[h + 1] ?? 0.0);
        final prf = (hourProfit[h] ?? 0.0) + (hourProfit[h + 1] ?? 0.0);
        salesTrend.add(DashboardChartPoint(date: startDate.add(Duration(hours: h)), label: hrText, value: val));
        profitTrend.add(DashboardChartPoint(date: startDate.add(Duration(hours: h)), label: hrText, value: prf));
      }
    } else if (range == DashboardDateRange.thisWeek) {
      // 7 days (Mon -> Sun)
      final List<String> daysName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final Map<int, double> daySales = {};
      final Map<int, double> dayProfit = {};

      for (final sale in currentSales) {
        final dayIndex = sale.date.weekday - 1; // 0 = Mon, 6 = Sun
        if (dayIndex >= 0 && dayIndex < 7) {
          daySales[dayIndex] = (daySales[dayIndex] ?? 0.0) + sale.totalAmount;
          
          double saleCost = 0.0;
          for (final item in sale.items) {
            double costPrice = item.purchasePrice;
            if (costPrice == 0.0) {
              final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
              costPrice = prod.purchasePrice;
            }
            saleCost += (costPrice * item.quantity);
          }
          dayProfit[dayIndex] = (dayProfit[dayIndex] ?? 0.0) + (sale.totalAmount - saleCost);
        }
      }

      for (int i = 0; i < 7; i++) {
        salesTrend.add(DashboardChartPoint(
          date: startDate.add(Duration(days: i)),
          label: daysName[i],
          value: daySales[i] ?? 0.0,
        ));
        profitTrend.add(DashboardChartPoint(
          date: startDate.add(Duration(days: i)),
          label: daysName[i],
          value: dayProfit[i] ?? 0.0,
        ));
      }
    } else if (range == DashboardDateRange.thisMonth) {
      // Day by day sales
      final daysInMonth = endDate.day;
      final Map<int, double> daySales = {};
      final Map<int, double> dayProfit = {};

      for (final sale in currentSales) {
        final d = sale.date.day;
        daySales[d] = (daySales[d] ?? 0.0) + sale.totalAmount;

        double saleCost = 0.0;
        for (final item in sale.items) {
          double costPrice = item.purchasePrice;
          if (costPrice == 0.0) {
            final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
            costPrice = prod.purchasePrice;
          }
          saleCost += (costPrice * item.quantity);
        }
        dayProfit[d] = (dayProfit[d] ?? 0.0) + (sale.totalAmount - saleCost);
      }

      for (int d = 1; d <= daysInMonth; d++) {
        salesTrend.add(DashboardChartPoint(
          date: DateTime(startDate.year, startDate.month, d),
          label: d.toString(),
          value: daySales[d] ?? 0.0,
        ));
        profitTrend.add(DashboardChartPoint(
          date: DateTime(startDate.year, startDate.month, d),
          label: d.toString(),
          value: dayProfit[d] ?? 0.0,
        ));
      }
    } else if (range == DashboardDateRange.thisYear) {
      // Jan -> Dec
      final List<String> monthsName = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final Map<int, double> monthSales = {};
      final Map<int, double> monthProfit = {};

      for (final sale in currentSales) {
        final m = sale.date.month; // 1 -> 12
        monthSales[m] = (monthSales[m] ?? 0.0) + sale.totalAmount;

        double saleCost = 0.0;
        for (final item in sale.items) {
          double costPrice = item.purchasePrice;
          if (costPrice == 0.0) {
            final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
            costPrice = prod.purchasePrice;
          }
          saleCost += (costPrice * item.quantity);
        }
        monthProfit[m] = (monthProfit[m] ?? 0.0) + (sale.totalAmount - saleCost);
      }

      for (int m = 1; m <= 12; m++) {
        salesTrend.add(DashboardChartPoint(
          date: DateTime(startDate.year, m, 1),
          label: monthsName[m - 1],
          value: monthSales[m] ?? 0.0,
        ));
        profitTrend.add(DashboardChartPoint(
          date: DateTime(startDate.year, m, 1),
          label: monthsName[m - 1],
          value: monthProfit[m] ?? 0.0,
        ));
      }
    } else {
      // Custom date range - auto bucket by length of range
      final diffDays = endDate.difference(startDate).inDays;
      if (diffDays <= 1) {
        // Hour by hour
        final Map<int, double> hourSales = {};
        final Map<int, double> hourProfit = {};
        for (final sale in currentSales) {
          final hr = sale.date.hour;
          hourSales[hr] = (hourSales[hr] ?? 0.0) + sale.totalAmount;
          
          double saleCost = 0.0;
          for (final item in sale.items) {
            double costPrice = item.purchasePrice;
            if (costPrice == 0.0) {
              final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
              costPrice = prod.purchasePrice;
            }
            saleCost += (costPrice * item.quantity);
          }
          hourProfit[hr] = (hourProfit[hr] ?? 0.0) + (sale.totalAmount - saleCost);
        }
        for (int h = 0; h < 24; h += 2) {
          final hrText = h == 0 ? '12 AM' : h < 12 ? '$h AM' : h == 12 ? '12 PM' : '${h - 12} PM';
          salesTrend.add(DashboardChartPoint(date: startDate.add(Duration(hours: h)), label: hrText, value: (hourSales[h] ?? 0.0) + (hourSales[h + 1] ?? 0.0)));
          profitTrend.add(DashboardChartPoint(date: startDate.add(Duration(hours: h)), label: hrText, value: (hourProfit[h] ?? 0.0) + (hourProfit[h + 1] ?? 0.0)));
        }
      } else if (diffDays <= 14) {
        // Day by day with date labels (e.g. 24 Aug)
        final formatter = DateFormat('d MMM');
        for (int i = 0; i <= diffDays; i++) {
          final targetDate = startDate.add(Duration(days: i));
          final salesSum = currentSales
              .where((s) => s.date.year == targetDate.year && s.date.month == targetDate.month && s.date.day == targetDate.day)
              .fold(0.0, (sum, s) => sum + s.totalAmount);

          final profitSum = currentSales
              .where((s) => s.date.year == targetDate.year && s.date.month == targetDate.month && s.date.day == targetDate.day)
              .fold(0.0, (sum, s) => sum + s.totalAmount - s.items.fold(0.0, (isum, item) {
                double cp = item.purchasePrice;
                if (cp == 0.0) {
                  final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
                  cp = prod.purchasePrice;
                }
                return isum + (cp * item.quantity);
              }));

          salesTrend.add(DashboardChartPoint(date: targetDate, label: formatter.format(targetDate), value: salesSum));
          profitTrend.add(DashboardChartPoint(date: targetDate, label: formatter.format(targetDate), value: profitSum));
        }
      } else {
        // Group by weekly buckets or monthly buckets
        // For simplicity: group into 8 intervals
        final intervalDays = (diffDays / 8).ceil();
        final formatter = DateFormat('d MMM');
        for (int i = 0; i < 8; i++) {
          final targetStartDate = startDate.add(Duration(days: i * intervalDays));
          var targetEndDate = DateTime(
            targetStartDate.year,
            targetStartDate.month,
            targetStartDate.day + intervalDays - 1,
            23,
            59,
            59,
            999,
          );
          if (targetEndDate.isAfter(endDate)) {
            targetEndDate = endDate;
          }

          final salesSum = currentSales
              .where((s) => !s.date.isBefore(targetStartDate) && !s.date.isAfter(targetEndDate))
              .fold(0.0, (sum, s) => sum + s.totalAmount);

          final profitSum = currentSales
              .where((s) => !s.date.isBefore(targetStartDate) && !s.date.isAfter(targetEndDate))
              .fold(0.0, (sum, s) => sum + s.totalAmount - s.items.fold(0.0, (isum, item) {
                double cp = item.purchasePrice;
                if (cp == 0.0) {
                  final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
                  cp = prod.purchasePrice;
                }
                return isum + (cp * item.quantity);
              }));

          salesTrend.add(DashboardChartPoint(
            date: targetStartDate,
            label: '${formatter.format(targetStartDate)}-${formatter.format(targetEndDate)}',
            value: salesSum,
          ));
          profitTrend.add(DashboardChartPoint(
            date: targetStartDate,
            label: '${formatter.format(targetStartDate)}-${formatter.format(targetEndDate)}',
            value: profitSum,
          ));
        }
      }
    }

    // 10. Period over period sales and profit changes
    double? salesChangePercentage;
    double? profitChangePercentage;

    double prevSalesTotal = prevSales.fold(0.0, (sum, s) => sum + s.totalAmount);
    double prevProfitTotal = prevSales.fold(0.0, (sum, s) => sum + s.totalAmount - s.items.fold(0.0, (isum, item) {
      double cp = item.purchasePrice;
      if (cp == 0.0) {
        final prod = allProducts.firstWhere((p) => p.uuid == item.productUuid, orElse: () => Product());
        cp = prod.purchasePrice;
      }
      return isum + (cp * item.quantity);
    }));

    if (prevSalesTotal > 0) {
      salesChangePercentage = ((totalSales - prevSalesTotal) / prevSalesTotal) * 100;
    }
    if (prevProfitTotal > 0) {
      profitChangePercentage = ((grossProfit - prevProfitTotal) / prevProfitTotal) * 100;
    }

    // 11. unified Recent transactions list
    final List<RecentTransactionData> recentTransactions = [];

    // Load actual recent items
    final recentSales = await isar.sales.filter().deletedEqualTo(false).sortByDateDesc().limit(10).findAll();
    final recentPurchases = await isar.purchases.filter().deletedEqualTo(false).sortByDateDesc().limit(10).findAll();
    final recentCustomerPayments = await isar.customerPayments.filter().deletedEqualTo(false).sortByDateDesc().limit(10).findAll();
    final recentSupplierPayments = await isar.supplierPayments.filter().deletedEqualTo(false).sortByDateDesc().limit(10).findAll();

    final supplierNameMap = {for (var s in allSuppliers) s.uuid: s.name};

    for (final sale in recentSales) {
      final due = sale.totalAmount - sale.amountReceived;
      final status = due <= 0
          ? 'Paid'
          : sale.amountReceived > 0
              ? 'Partial'
              : 'Pending';
      recentTransactions.add(RecentTransactionData(
        id: sale.uuid,
        date: sale.date,
        referenceNumber: 'Bill #${sale.isarId}',
        partyName: sale.buyerName ?? 'Walk-in Customer',
        type: TransactionType.sale,
        amount: sale.totalAmount,
        paymentStatus: status,
        originalRecord: sale,
      ));
    }

    for (final p in recentPurchases) {
      final due = p.totalAmount - p.amountPaid;
      final status = due <= 0
          ? 'Paid'
          : p.amountPaid > 0
              ? 'Partial'
              : 'Pending';
      recentTransactions.add(RecentTransactionData(
        id: p.uuid,
        date: p.date,
        referenceNumber: 'PO #${p.isarId}',
        partyName: supplierNameMap[p.supplierUuid] ?? 'Supplier',
        type: TransactionType.purchase,
        amount: p.totalAmount,
        paymentStatus: status,
        originalRecord: p,
      ));
    }

    for (final cp in recentCustomerPayments) {
      recentTransactions.add(RecentTransactionData(
        id: cp.uuid,
        date: cp.date,
        referenceNumber: 'Recipt #${cp.isarId}',
        partyName: cp.customerName,
        type: TransactionType.customerPayment,
        amount: cp.amountReceived,
        paymentStatus: 'Receipt',
        originalRecord: cp,
      ));
    }

    for (final sp in recentSupplierPayments) {
      recentTransactions.add(RecentTransactionData(
        id: sp.uuid,
        date: sp.date,
        referenceNumber: 'Payment #${sp.isarId}',
        partyName: supplierNameMap[sp.supplierUuid] ?? 'Supplier',
        type: TransactionType.supplierPayment,
        amount: sp.amount,
        paymentStatus: 'Paid Out',
        originalRecord: sp,
      ));
    }

    // Sort combined recent transactions by date desc and limit to 10
    recentTransactions.sort((a, b) => b.date.compareTo(a.date));
    final displayRecent = recentTransactions.take(10).toList();

    // 12. Create alerts list
    final List<DashboardAlert> alerts = [];

    if (lowStockItemCount > 0) {
      alerts.add(DashboardAlert(
        message: '$lowStockItemCount products are running low on stock.',
        severity: AlertSeverity.warning,
        actionLabel: 'View Low Stock',
      ));
    }

    if (outOfStockItemCount > 0) {
      alerts.add(DashboardAlert(
        message: '$outOfStockItemCount products are out of stock.',
        severity: AlertSeverity.danger,
        actionLabel: 'Reorder',
      ));
    }

    if (receivablesTotal > 15000) {
      alerts.add(DashboardAlert(
        message: 'Total receivables are high: ${NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0).format(receivablesTotal)} pending.',
        severity: AlertSeverity.warning,
        actionLabel: 'Collect',
      ));
    }

    if (unusualZeroProfitSales > 0) {
      alerts.add(DashboardAlert(
        message: 'Detected $unusualZeroProfitSales sales with zero or negative gross profit.',
        severity: AlertSeverity.info,
        actionLabel: 'Review',
      ));
    }

    return DashboardData(
      dateRange: range,
      startDate: startDate,
      endDate: endDate,
      totalSales: totalSales,
      salesCount: salesCount,
      averageBillValue: averageBillValue,
      grossProfit: grossProfit,
      profitMargin: profitMargin,
      totalPurchases: totalPurchases,
      purchasesCount: purchasesCount,
      receivablesTotal: receivablesTotal,
      receivablesCustomerCount: receivablesCustomerCount,
      payablesTotal: payablesTotal,
      payablesSupplierCount: payablesSupplierCount,
      totalInventoryItems: totalInventoryItems,
      totalInventoryQuantity: totalInventoryQuantity,
      estimatedInventoryValue: estimatedInventoryValue,
      lowStockItemCount: lowStockItemCount,
      outOfStockItemCount: outOfStockItemCount,
      cashReceived: cashReceived,
      upiReceived: upiDigitalSum,
      bankReceived: bankReceivedSum,
      otherReceived: otherReceivedSum,
      salesTrend: salesTrend,
      profitTrend: profitTrend,
      paymentBreakdown: paymentBreakdown,
      topProducts: topProducts,
      recentTransactions: displayRecent,
      lowStockProducts: lowStockProducts,
      topReceivables: topReceivables,
      topPayables: topPayables,
      salesChangePercentage: salesChangePercentage,
      profitChangePercentage: profitChangePercentage,
      alerts: alerts,
    );
  }
}
