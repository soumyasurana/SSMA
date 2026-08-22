enum ReportTimePreset {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  financialYear,
  allTime,
  custom,
}

class BusinessReportData {
  final DateTime startDate;
  final DateTime endDate;
  final String presetLabel;

  // 1. Profit & Loss Metrics
  final double grossSales;
  final double totalDiscountsOrCharges;
  final double netSales;
  final double cogs; // Cost of goods sold
  final double grossProfit;
  final double profitMarginPercentage;
  final int totalOrders;
  final double averageOrderValue;
  final int totalItemsSold;

  // 2. Cash Flow & Liquidity
  final double salesCashCollected;
  final double customerReceiptsCollected;
  final double totalCashInflow;
  final double purchaseCashPaid;
  final double supplierPaymentsPaid;
  final double totalCashOutflow;
  final double netCashFlow;

  // 3. Payment Methods Breakdown
  final List<PaymentMethodStat> paymentMethods;

  // 4. Sales Distribution
  final double cashSalesTotal;
  final double creditSalesTotal;
  final double cashSalesRatio; // e.g. 70.5%
  final double creditSalesRatio; // e.g. 29.5%

  // 5. Working Capital & Dues
  final double totalCustomerReceivables; // total outstanding from all customers
  final double periodCustomerReceivablesAdded; // unpaid credit sales during this period
  final double totalSupplierPayables; // total outstanding to all suppliers
  final double periodSupplierPayablesAdded; // unpaid purchases during this period
  final double netWorkingCapitalPosition; // Receivables - Payables

  // 6. Inventory & Godown Health
  final int totalShopProductTypes;
  final int totalShopStockUnits;
  final double shopInventoryValuationAtCost;
  final double shopInventoryValuationAtRetail;
  final double potentialInventoryProfit;
  final int lowStockCount;
  final int outOfStockCount;

  final int totalGodownItemTypes;
  final int totalGodownStockUnits;
  final double godownInventoryValuationAtCost;
  final int totalGodownMovementsInPeriod;
  final int godownTransfersToShopUnits;

  // 7. Rankings & Lists
  final List<ProductReportItem> topProductsByRevenue;
  final List<ProductReportItem> topProductsByProfit;
  final List<ProductReportItem> topProductsByQuantity;
  final List<ProductReportItem> deadOrLowMovingProducts;

  final List<CustomerReportItem> topCustomersByRevenue;
  final List<CustomerReportItem> topCustomersByOutstanding;

  final List<SupplierReportItem> topSuppliersByPurchases;
  final List<SupplierReportItem> topSuppliersByOutstanding;

  const BusinessReportData({
    required this.startDate,
    required this.endDate,
    required this.presetLabel,
    required this.grossSales,
    required this.totalDiscountsOrCharges,
    required this.netSales,
    required this.cogs,
    required this.grossProfit,
    required this.profitMarginPercentage,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.totalItemsSold,
    required this.salesCashCollected,
    required this.customerReceiptsCollected,
    required this.totalCashInflow,
    required this.purchaseCashPaid,
    required this.supplierPaymentsPaid,
    required this.totalCashOutflow,
    required this.netCashFlow,
    required this.paymentMethods,
    required this.cashSalesTotal,
    required this.creditSalesTotal,
    required this.cashSalesRatio,
    required this.creditSalesRatio,
    required this.totalCustomerReceivables,
    required this.periodCustomerReceivablesAdded,
    required this.totalSupplierPayables,
    required this.periodSupplierPayablesAdded,
    required this.netWorkingCapitalPosition,
    required this.totalShopProductTypes,
    required this.totalShopStockUnits,
    required this.shopInventoryValuationAtCost,
    required this.shopInventoryValuationAtRetail,
    required this.potentialInventoryProfit,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalGodownItemTypes,
    required this.totalGodownStockUnits,
    required this.godownInventoryValuationAtCost,
    required this.totalGodownMovementsInPeriod,
    required this.godownTransfersToShopUnits,
    required this.topProductsByRevenue,
    required this.topProductsByProfit,
    required this.topProductsByQuantity,
    required this.deadOrLowMovingProducts,
    required this.topCustomersByRevenue,
    required this.topCustomersByOutstanding,
    required this.topSuppliersByPurchases,
    required this.topSuppliersByOutstanding,
  });
}

class PaymentMethodStat {
  final String method;
  final double amount;
  final double percentage;
  final int transactionCount;

  const PaymentMethodStat({
    required this.method,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

class ProductReportItem {
  final String productUuid;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double totalCost;
  final double profit;
  final double marginPercentage;
  final int currentStock;

  const ProductReportItem({
    required this.productUuid,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.totalCost,
    required this.profit,
    required this.marginPercentage,
    required this.currentStock,
  });
}

class CustomerReportItem {
  final String customerUuid;
  final String customerName;
  final String? phone;
  final int orderCount;
  final double totalBilled;
  final double totalPaid;
  final double currentOutstanding;

  const CustomerReportItem({
    required this.customerUuid,
    required this.customerName,
    this.phone,
    required this.orderCount,
    required this.totalBilled,
    required this.totalPaid,
    required this.currentOutstanding,
  });
}

class SupplierReportItem {
  final String supplierUuid;
  final String supplierName;
  final String? phone;
  final int purchaseCount;
  final double totalPurchased;
  final double totalPaid;
  final double currentBalanceDue;

  const SupplierReportItem({
    required this.supplierUuid,
    required this.supplierName,
    this.phone,
    required this.purchaseCount,
    required this.totalPurchased,
    required this.totalPaid,
    required this.currentBalanceDue,
  });
}
