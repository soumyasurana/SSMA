import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:intl/intl.dart';

class ProfitChart extends StatelessWidget {
  final List<DashboardChartPoint> salesPoints;
  final List<DashboardChartPoint> profitPoints;

  const ProfitChart({
    super.key,
    required this.salesPoints,
    required this.profitPoints,
  });

  String _formatAxisValue(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return '₹${value.toStringAsFixed(0)}';
    }
  }

  String _formatTooltipValue(double value) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasData = salesPoints.any((p) => p.value > 0) || profitPoints.any((p) => p.value > 0);

    if (!hasData) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No financial trends available for this period',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    double maxVal = 0.0;
    for (final dp in salesPoints) {
      if (dp.value > maxVal) maxVal = dp.value;
    }
    for (final dp in profitPoints) {
      if (dp.value > maxVal) maxVal = dp.value;
    }
    final double maxY = maxVal > 0 ? maxVal * 1.15 : 100.0;

    final List<FlSpot> salesSpots = [];
    final List<FlSpot> profitSpots = [];

    for (int i = 0; i < salesPoints.length; i++) {
      salesSpots.add(FlSpot(i.toDouble(), salesPoints[i].value));
    }
    for (int i = 0; i < profitPoints.length; i++) {
      profitSpots.add(FlSpot(i.toDouble(), profitPoints[i].value));
    }

    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales vs. Profit Performance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey[800],
                  ),
                ),
                Row(
                  children: [
                    _buildLegendItem(Colors.indigo, 'Sales', isDark),
                    const SizedBox(width: 12),
                    _buildLegendItem(Colors.green, 'Profit', isDark),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  maxY: maxY,
                  minY: 0,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => isDark ? Colors.grey[850]! : Colors.grey[900]!,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final label = touchedSpot.barIndex == 0 ? 'Sales' : 'Profit';
                          final valColor = touchedSpot.barIndex == 0 ? Colors.indigoAccent : Colors.greenAccent;
                          return LineTooltipItem(
                            '$label: ',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            children: [
                              TextSpan(
                                text: _formatTooltipValue(touchedSpot.y),
                                style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(
                              _formatAxisValue(value),
                              style: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= salesPoints.length) {
                            return const SizedBox.shrink();
                          }
                          // Decimate label count if there are too many
                          if (salesPoints.length > 15) {
                            if (index % 5 != 0 && index != salesPoints.length - 1) {
                              return const SizedBox.shrink();
                            }
                          } else if (salesPoints.length > 7) {
                            if (index % 2 != 0) {
                              return const SizedBox.shrink();
                            }
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 6,
                            child: Text(
                              salesPoints[index].label,
                              style: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Line 1: Sales
                    LineChartBarData(
                      spots: salesSpots,
                      isCurved: true,
                      color: Colors.indigo,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.indigo.withValues(alpha: 0.05),
                      ),
                    ),
                    // Line 2: Profit
                    LineChartBarData(
                      spots: profitSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
