import 'package:flutter/material.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:intl/intl.dart';

class TopProductsSection extends StatefulWidget {
  final List<TopProductData> products;

  const TopProductsSection({super.key, required this.products});

  @override
  State<TopProductsSection> createState() => _TopProductsSectionState();
}

class _TopProductsSectionState extends State<TopProductsSection> {
  int _sortByType = 0; // 0 = Qty, 1 = Revenue, 2 = Profit

  List<TopProductData> get _sortedProducts {
    final list = List<TopProductData>.from(widget.products);
    if (_sortByType == 0) {
      list.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    } else if (_sortByType == 1) {
      list.sort((a, b) => b.revenue.compareTo(a.revenue));
    } else {
      list.sort((a, b) => b.profit.compareTo(a.profit));
    }
    return list.take(5).toList(); // Show top 5
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.products.isEmpty) {
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
              Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No product sales recorded',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final currentList = _sortedProducts;

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
                  'Top Performing Products',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey[800],
                  ),
                ),
                // Tab selectors
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      _buildTabButton(0, 'Qty'),
                      _buildTabButton(1, 'Revenue'),
                      _buildTabButton(2, 'Profit'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentList.length,
              separatorBuilder: (context, index) => Divider(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                height: 1,
              ),
              itemBuilder: (context, index) {
                final prod = currentList[index];
                final rank = index + 1;

                Color rankColor = Colors.grey[600]!;
                if (rank == 1) rankColor = Colors.amber.shade700;
                if (rank == 2) rankColor = Colors.blueGrey;
                if (rank == 3) rankColor = Colors.brown;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            color: rankColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.productName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.blueGrey[800],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${prod.quantitySold} units sold',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(prod.revenue),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[200] : Colors.blueGrey[700],
                            ),
                          ),
                          Text(
                            'Profit: ${currencyFormat.format(prod.profit)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: prod.profit >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildTabButton(int type, String label) {
    final isSelected = _sortByType == type;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sortByType = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.grey[700] : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? (isDark ? Colors.white : Colors.indigo)
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
