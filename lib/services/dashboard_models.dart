import 'package:ssma/models/sale.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/product.dart';

enum DashboardDateRange { today, thisWeek, thisMonth, thisYear, custom }

class DashboardData {
  final DashboardDateRange dateRange;
  final DateTime startDate;
  final DateTime endDate;

  // KPI Metrics
  final double totalSales;
  final int salesCount;
  final double averageBillValue;

  final double grossProfit;
  final double profitMargin; // percentage, e.g. 15.5 for 15.5%

  final double totalPurchases;
  final int purchasesCount;

  final double receivablesTotal;
  final int receivablesCustomerCount;

  final double payablesTotal;
  final int payablesSupplierCount;

  final int totalInventoryItems;
  final int totalInventoryQuantity;
  final double estimatedInventoryValue;
  final int lowStockItemCount;
  final int outOfStockItemCount;

  final double cashReceived;
  final double upiReceived;
  final double bankReceived;
  final double otherReceived;

  // Visualizations Data
  final List<DashboardChartPoint> salesTrend;
  final List<DashboardChartPoint> profitTrend;
  final List<PaymentMethodBreakdown> paymentBreakdown;
  final List<TopProductData> topProducts;
  final List<RecentTransactionData> recentTransactions;
  final List<LowStockProductData> lowStockProducts;

  // Credit Outstanding details
  final List<OutstandingCustomerData> topReceivables;
  final List<OutstandingSupplierData> topPayables;

  // Period-over-period comparisons
  final double? salesChangePercentage; // null if not enough historical data
  final double? profitChangePercentage;

  // Alerts
  final List<DashboardAlert> alerts;

  DashboardData({
    required this.dateRange,
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.salesCount,
    required this.averageBillValue,
    required this.grossProfit,
    required this.profitMargin,
    required this.totalPurchases,
    required this.purchasesCount,
    required this.receivablesTotal,
    required this.receivablesCustomerCount,
    required this.payablesTotal,
    required this.payablesSupplierCount,
    required this.totalInventoryItems,
    required this.totalInventoryQuantity,
    required this.estimatedInventoryValue,
    required this.lowStockItemCount,
    required this.outOfStockItemCount,
    required this.cashReceived,
    required this.upiReceived,
    required this.bankReceived,
    required this.otherReceived,
    required this.salesTrend,
    required this.profitTrend,
    required this.paymentBreakdown,
    required this.topProducts,
    required this.recentTransactions,
    required this.lowStockProducts,
    required this.topReceivables,
    required this.topPayables,
    this.salesChangePercentage,
    this.profitChangePercentage,
    required this.alerts,
  });
}

class DashboardChartPoint {
  final DateTime date;
  final String label; // e.g. "Mon", "12 PM", "Jan"
  final double value; // sales or profit amount

  DashboardChartPoint({
    required this.date,
    required this.label,
    required this.value,
  });
}

class PaymentMethodBreakdown {
  final String method;
  final double amount;
  final double percentage;

  PaymentMethodBreakdown({
    required this.method,
    required this.amount,
    required this.percentage,
  });
}

class TopProductData {
  final String productName;
  final int quantitySold;
  final double revenue;
  final double profit;

  TopProductData({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
  });
}

enum TransactionType {
  sale,
  purchase,
  customerPayment,
  supplierPayment
}

class RecentTransactionData {
  final String id; // uuid
  final DateTime date;
  final String referenceNumber; // isarId or uuid prefix
  final String partyName; // customer or supplier name
  final TransactionType type;
  final double amount;
  final String paymentStatus; // e.g., "Paid", "Pending", "Partial"
  final Object originalRecord; // Sale or Purchase or CustomerPayment or SupplierPayment

  RecentTransactionData({
    required this.id,
    required this.date,
    required this.referenceNumber,
    required this.partyName,
    required this.type,
    required this.amount,
    required this.paymentStatus,
    required this.originalRecord,
  });
}

class LowStockProductData {
  final String productName;
  final int currentQuantity;
  final double sellingPrice;

  LowStockProductData({
    required this.productName,
    required this.currentQuantity,
    required this.sellingPrice,
  });
}

class OutstandingCustomerData {
  final String customerUuid;
  final String customerName;
  final double outstandingAmount;

  OutstandingCustomerData({
    required this.customerUuid,
    required this.customerName,
    required this.outstandingAmount,
  });
}

class OutstandingSupplierData {
  final String supplierUuid;
  final String supplierName;
  final double outstandingAmount;

  OutstandingSupplierData({
    required this.supplierUuid,
    required this.supplierName,
    required this.outstandingAmount,
  });
}

enum AlertSeverity { info, warning, danger }

class DashboardAlert {
  final String message;
  final AlertSeverity severity;
  final String? actionLabel;

  DashboardAlert({
    required this.message,
    required this.severity,
    this.actionLabel,
  });
}
