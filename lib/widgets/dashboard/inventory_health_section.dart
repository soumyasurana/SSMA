import 'package:flutter/material.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:ssma/screens/inventory_screen.dart';
import 'package:intl/intl.dart';

class InventoryHealthSection extends StatelessWidget {
  final int totalItems;
  final int totalQuantity;
  final double estimatedValue;
  final int lowStockCount;
  final int outOfStockCount;
  final List<LowStockProductData> lowStockProducts;

  const InventoryHealthSection({
    super.key,
    required this.totalItems,
    required this.totalQuantity,
    required this.estimatedValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.lowStockProducts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  'Inventory Overview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InventoryScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View Inventory',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Inventory Stat Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildMiniStat(
                  label: 'Unique Items',
                  value: totalItems.toString(),
                  isDark: isDark,
                ),
                _buildMiniStat(
                  label: 'Total Stock Qty',
                  value: totalQuantity.toString(),
                  isDark: isDark,
                ),
                _buildMiniStat(
                  label: 'Stock Value (Cost)',
                  value: currencyFormat.format(estimatedValue),
                  isDark: isDark,
                ),
                _buildMiniStat(
                  label: 'Out of Stock',
                  value: outOfStockCount.toString(),
                  valueColor: outOfStockCount > 0 ? Colors.red : null,
                  isDark: isDark,
                ),
              ],
            ),
            if (lowStockProducts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Low Stock Items (${lowStockProducts.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.blueGrey[700],
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowStockProducts.take(4).toList().length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final item = lowStockProducts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.blueGrey[800],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.currentQuantity == 0
                                ? Colors.red.withValues(alpha: 0.12)
                                : Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.currentQuantity == 0 ? 'Out of Stock' : 'Qty: ${item.currentQuantity}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.currentQuantity == 0 ? Colors.red.shade700 : Colors.orange.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currencyFormat.format(item.sellingPrice),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    Color? valueColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.blueGrey[50]!.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.blueGrey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? (isDark ? Colors.white : Colors.blueGrey[800]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
