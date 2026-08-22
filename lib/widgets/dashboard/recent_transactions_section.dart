import 'package:flutter/material.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/screens/new_sale_screen.dart';
import 'package:ssma/screens/customer_detail_screen.dart';
import 'package:ssma/screens/supplier_detail_screen.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';

class RecentTransactionsSection extends StatelessWidget {
  final List<RecentTransactionData> transactions;
  final VoidCallback? onViewAll;

  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Colors.green;
      case TransactionType.purchase:
        return Colors.red;
      case TransactionType.customerPayment:
        return Colors.teal;
      case TransactionType.supplierPayment:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Icons.arrow_upward;
      case TransactionType.purchase:
        return Icons.arrow_downward;
      case TransactionType.customerPayment:
        return Icons.payments;
      case TransactionType.supplierPayment:
        return Icons.local_shipping;
    }
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.customerPayment:
        return 'Customer Payment';
      case TransactionType.supplierPayment:
        return 'Supplier Payment';
    }
  }

  Future<void> _handleRowTap(BuildContext context, RecentTransactionData tx) async {
    final isar = DBService.isar;

    try {
      if (tx.type == TransactionType.sale) {
        final sale = tx.originalRecord as Sale;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewSaleScreen(existingSale: sale)),
        );
      } else if (tx.type == TransactionType.customerPayment) {
        final customerUuid = (tx.originalRecord as CustomerPayment).customerUuid;
        final customer = await isar.customers.filter().uuidEqualTo(customerUuid).findFirst();
        if (customer != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer)),
          );
        }
      } else if (tx.type == TransactionType.purchase) {
        final supplierUuid = (tx.originalRecord as Purchase).supplierUuid;
        final supplier = await isar.suppliers.filter().uuidEqualTo(supplierUuid).findFirst();
        if (supplier != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplier: supplier)),
          );
        }
      } else if (tx.type == TransactionType.supplierPayment) {
        final supplierUuid = (tx.originalRecord as SupplierPayment).supplierUuid;
        final supplier = await isar.suppliers.filter().uuidEqualTo(supplierUuid).findFirst();
        if (supplier != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplier: supplier)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open transaction detail: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Card(
        elevation: 0,
        color: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
        child: Container(
          height: 150,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No transactions recorded',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey[800],
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => Divider(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                height: 1,
              ),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final txColor = _getTypeColor(tx.type);

                return ListTile(
                  onTap: () => _handleRowTap(context, tx),
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: txColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTypeIcon(tx.type),
                      color: txColor,
                      size: 18,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tx.partyName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blueGrey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currencyFormat.format(tx.amount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: tx.type == TransactionType.purchase || tx.type == TransactionType.supplierPayment
                              ? Colors.red.shade600
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tx.referenceNumber} • ${_getTypeLabel(tx.type)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tx.paymentStatus == 'Paid' || tx.paymentStatus == 'Receipt'
                              ? Colors.green.withValues(alpha: 0.1)
                              : tx.paymentStatus == 'Partial'
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tx.paymentStatus,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: tx.paymentStatus == 'Paid' || tx.paymentStatus == 'Receipt'
                                ? Colors.green.shade700
                                : tx.paymentStatus == 'Partial'
                                    ? Colors.orange.shade700
                                    : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
