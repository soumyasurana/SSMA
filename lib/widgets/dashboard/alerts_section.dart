import 'package:flutter/material.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:ssma/screens/low_stock_screen.dart';
import 'package:ssma/screens/customer_screen.dart';
import 'package:ssma/screens/sales_history_screen.dart';

class AlertsSection extends StatelessWidget {
  final List<DashboardAlert> alerts;

  const AlertsSection({super.key, required this.alerts});

  void _handleAction(BuildContext context, String actionLabel) {
    if (actionLabel == 'View Low Stock' || actionLabel == 'Reorder') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LowStockScreen()),
      );
    } else if (actionLabel == 'Collect') {
      // Navigate to Customers tab. We don't have tab controller access here,
      // but we can open CustomerScreen directly as a push route for now.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomerScreen()),
      );
    } else if (actionLabel == 'Review') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
      );
    }
  }

  Color _getBgColor(AlertSeverity severity, bool isDark) {
    switch (severity) {
      case AlertSeverity.danger:
        return isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50;
      case AlertSeverity.warning:
        return isDark ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.amber.shade50;
      case AlertSeverity.info:
        return isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : Colors.blue.shade50;
    }
  }

  Color _getBorderColor(AlertSeverity severity, bool isDark) {
    switch (severity) {
      case AlertSeverity.danger:
        return isDark ? Colors.red.shade800 : Colors.red.shade200;
      case AlertSeverity.warning:
        return isDark ? Colors.amber.shade800 : Colors.amber.shade200;
      case AlertSeverity.info:
        return isDark ? Colors.blue.shade800 : Colors.blue.shade200;
    }
  }

  Color _getTextColor(AlertSeverity severity, bool isDark) {
    switch (severity) {
      case AlertSeverity.danger:
        return isDark ? Colors.red.shade100 : Colors.red.shade800;
      case AlertSeverity.warning:
        return isDark ? Colors.amber.shade100 : Colors.amber.shade800;
      case AlertSeverity.info:
        return isDark ? Colors.blue.shade100 : Colors.blue.shade800;
    }
  }

  IconData _getIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.danger:
        return Icons.error_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
          child: Text(
            'Attention Required',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.blueGrey[800],
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alerts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            final bgColor = _getBgColor(alert.severity, isDark);
            final borderColor = _getBorderColor(alert.severity, isDark);
            final textColor = _getTextColor(alert.severity, isDark);

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    _getIcon(alert.severity),
                    color: textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      alert.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (alert.actionLabel != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _handleAction(context, alert.actionLabel!),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: isDark ? Colors.white10 : Colors.white60,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        alert.actionLabel!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
