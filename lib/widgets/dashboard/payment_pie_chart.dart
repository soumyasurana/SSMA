import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:intl/intl.dart';

class PaymentPieChart extends StatelessWidget {
  final List<PaymentMethodBreakdown> breakdown;

  const PaymentPieChart({super.key, required this.breakdown});

  Color _getColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'upi / digital':
      case 'upi':
      case 'digital':
        return Colors.purple;
      case 'bank transfer':
      case 'bank':
        return Colors.blue;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double totalAmount = breakdown.fold(0.0, (sum, b) => sum + b.amount);
    final hasData = totalAmount > 0;

    if (!hasData) {
      return Card(
        elevation: 0,
        color: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
        child: Container(
          height: 200,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No payment breakdown data available',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final List<PieChartSectionData> sections = [];
    for (int i = 0; i < breakdown.length; i++) {
      final item = breakdown[i];
      if (item.amount == 0) continue;
      sections.add(
        PieChartSectionData(
          color: _getColor(item.method),
          value: item.amount,
          title: '${item.percentage.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

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
            Text(
              'Payment Method Collections',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        startDegreeOffset: -90,
                        sections: sections,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: breakdown.map((item) {
                      final itemColor = _getColor(item.method);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: itemColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.method,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey[300] : Colors.blueGrey[700],
                                    ),
                                  ),
                                  Text(
                                    '${currencyFormat.format(item.amount)} (${item.percentage.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
