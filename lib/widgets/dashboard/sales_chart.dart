import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:intl/intl.dart';

class SalesChart extends StatelessWidget {
  final List<DashboardChartPoint> dataPoints;

  const SalesChart({super.key, required this.dataPoints});

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

    // Filter points and check if empty
    final hasData = dataPoints.any((p) => p.value > 0);

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
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No sales recorded for this period',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    double maxVal = 0.0;
    for (final dp in dataPoints) {
      if (dp.value > maxVal) maxVal = dp.value;
    }
    // Set nice upper boundary
    final double maxY = maxVal > 0 ? maxVal * 1.15 : 100.0;

    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < dataPoints.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dataPoints[i].value,
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigo.shade400],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: dataPoints.length > 15 ? 8 : 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
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
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sales Revenue Trend',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => isDark ? Colors.grey[850]! : Colors.grey[900]!,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${dataPoints[group.x].label}\n',
                          const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: _formatTooltipValue(rod.toY),
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        );
                      },
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
                          // Display a few interval labels
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
                          if (index < 0 || index >= dataPoints.length) {
                            return const SizedBox.shrink();
                          }
                          // Decimate label count if there are too many (e.g. daily month view)
                          if (dataPoints.length > 15) {
                            if (index % 5 != 0 && index != dataPoints.length - 1) {
                              return const SizedBox.shrink();
                            }
                          } else if (dataPoints.length > 7) {
                            if (index % 2 != 0) {
                              return const SizedBox.shrink();
                            }
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 6,
                            child: Text(
                              dataPoints[index].label,
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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      strokeWidth: 1,
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
