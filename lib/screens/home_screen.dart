import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;

import 'low_stock_screen.dart';
import 'supplier_screen.dart';
import 'report_screen.dart';
import 'package:ssma/widgets/sync_indicator.dart';
import 'package:ssma/screens/sync_settings_screen_v2.dart';

// ---------------------------------------------------------------------------
// Design tokens — keep colors/spacing centralized so the screen stays
// consistent and easy to re-theme later.
// ---------------------------------------------------------------------------
class _Palette {
  _Palette._();
  static const primary = Colors.indigo;
  static const primaryDark = Color(0xFF3B4EC4);
  static const border = Color(0xFFEAEAF0);
  static const skeletonBase = Color(0xFFE9E9EF);
  static const skeletonHighlight = Color(0xFFF6F6F9);
  static const textPrimary = Color(0xFF1B1B2A);
  static const textSecondary = Color(0xFF6E7280);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalSales = 0, inMoney = 0, profit = 0;
  bool _showProfit = false;
  int totalCustomers = 0, lowStockCount = 0;

  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    loadStats();
    syncV2?.statusNotifier.addListener(_onSyncChanged);
  }

  void _onSyncChanged() {
    if (mounted) {
      loadStats();
    }
  }

  @override
  void dispose() {
    syncV2?.statusNotifier.removeListener(_onSyncChanged);
    super.dispose();
  }

  Future<void> loadStats() async {
    if (!_loading) {
      setState(() {
        _refreshing = true;
        _error = null;
      });
    }

    try {
      final List<Sale> sales = await DBService.getAllSales();
      final products = await DBService.getProducts();
      final customers = await DBService.getCustomers();

      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);

      double todaySales = 0;
      double cashReceived = 0;
      double totalCost = 0;

      for (final sale in sales) {
        final saleDate =
            DateTime(sale.date.year, sale.date.month, sale.date.day);

        if (saleDate == todayOnly) {
          todaySales += sale.totalAmount;
          cashReceived += sale.amountReceived;

          for (final item in sale.items) {
            totalCost += item.purchasePrice * item.quantity;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        totalSales = todaySales;
        inMoney = cashReceived;
        profit = todaySales - totalCost;
        totalCustomers = customers.length;
        lowStockCount = products.where((p) => p.quantity < 5).length;
        _loading = false;
        _refreshing = false;
        _lastUpdated = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = "Couldn't load your dashboard. Check your data and try again.";
      });
    }
  }

  void _goToSyncSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SyncSettingsScreenV2()),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }

  /// Formats a value as ₹ currency using Indian digit grouping
  /// (e.g. 1234567.5 -> ₹12,34,567.50), without needing the intl package.
  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final fixed = value.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    final grouped = _indianGroup(parts[0]);
    return '${isNegative ? '-' : ''}₹$grouped.${parts[1]}';
  }

  String _indianGroup(String digits) {
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    var remaining = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) groups.insert(0, remaining);
    return '${groups.join(',')},$last3';
  }

  @override
  Widget build(BuildContext context) {
    // Clamp text scaling so large accessibility font sizes can't blow up
    // the stat grid on small phones.
    final mq = MediaQuery.of(context);
    final clampedScaler =
        mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.25);

    return MediaQuery(
      data: mq.copyWith(textScaler: clampedScaler),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: _Palette.primary,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Open menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 4),
              child: SyncIndicator(),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 24,
                  20,
                  24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_Palette.primary, _Palette.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.store, color: Colors.white),
                    ),
                    SizedBox(width: 14),
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _DrawerTile(
                icon: Icons.local_shipping_outlined,
                title: 'Supplier Records',
                subtitle: 'Manage suppliers & orders',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupplierScreen()),
                  );
                },
              ),
              _DrawerTile(
                icon: Icons.bar_chart_outlined,
                title: 'Reports',
                subtitle: 'Sales & performance insights',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportScreen()),
                  );
                },
              ),
              _DrawerTile(
                icon: Icons.sync,
                title: 'Sync Settings',
                subtitle: 'Manage cloud synchronization',
                onTap: () {
                  Navigator.pop(context);
                  _goToSyncSettings();
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: _Palette.primary,
            onRefresh: loadStats,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isWide = width > 600;
                final crossAxisCount = isWide ? 4 : 2;
                final aspectRatio =
                    isWide ? 1.35 : (width < 340 ? 1.05 : 1.2);

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _Palette.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Today's Overview",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _Palette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_lastUpdated != null && !_loading)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  if (_refreshing)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  Text(
                                    'Updated ${_formatTime(_lastUpdated!)}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: _Palette.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_loading)
                        _StatGridSkeleton(
                          crossAxisCount: crossAxisCount,
                          aspectRatio: aspectRatio,
                        )
                      else if (_error != null)
                        _ErrorState(message: _error!, onRetry: loadStats)
                      else ...[
                        GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: aspectRatio,
                          children: [
                            _StatTile(
                              icon: Icons.attach_money,
                              label: 'Total Sales Today',
                              value: _formatCurrency(totalSales),
                              gradient: const [
                                Color(0xFF4CAF6D),
                                Color(0xFF2E8B4E)
                              ],
                            ),
                            _StatTile(
                              icon: Icons.payments_outlined,
                              label: 'Cash Received Today',
                              value: _formatCurrency(inMoney),
                              gradient: const [
                                Color(0xFF3AB6A6),
                                Color(0xFF1F8C7E)
                              ],
                            ),
                            _StatTile(
                              icon: Icons.people_outline,
                              label: 'Total Customers',
                              value: totalCustomers.toString(),
                              gradient: const [
                                Color(0xFF4C8DFF),
                                Color(0xFF2E63D6)
                              ],
                            ),
                            _StatTile(
                              icon: Icons.warning_amber_rounded,
                              label: 'Low Stock Products',
                              value: lowStockCount.toString(),
                              gradient: const [
                                Color(0xFFEF6B6B),
                                Color(0xFFD1435A)
                              ],
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LowStockScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _Palette.primary,
                              side: const BorderSide(color: _Palette.primary),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => _showProfit = !_showProfit);
                            },
                            icon: Icon(_showProfit
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            label: Text(
                                _showProfit ? 'Hide Profit' : 'Show Profit'),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: _showProfit
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: _ProfitCard(
                                    value: _formatCurrency(profit),
                                    isPositive: profit >= 0,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat tile
// ---------------------------------------------------------------------------
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      button: onTap != null,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _Palette.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _Palette.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _Palette.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profit card
// ---------------------------------------------------------------------------
class _ProfitCard extends StatelessWidget {
  const _ProfitCard({required this.value, required this.isPositive});

  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final colors = isPositive
        ? const [Color(0xFF6B4CE6), Color(0xFF4B2FBF)]
        : const [Color(0xFFEF6B6B), Color(0xFFD1435A)];

    return Semantics(
      label: 'Profit today $value',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profit Today',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drawer tile
// ---------------------------------------------------------------------------
class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _Palette.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _Palette.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: _Palette.textSecondary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 36, color: _Palette.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: _Palette.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _Palette.primary,
              side: const BorderSide(color: _Palette.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading state
// ---------------------------------------------------------------------------
class _StatGridSkeleton extends StatelessWidget {
  const _StatGridSkeleton({
    required this.crossAxisCount,
    required this.aspectRatio,
  });

  final int crossAxisCount;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: aspectRatio,
      children: List.generate(4, (_) => const _SkeletonCard()),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.border),
      ),
      child: const _Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ShimmerBox(width: 40, height: 40, radius: 12),
            _ShimmerBoxGroup(),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBoxGroup extends StatelessWidget {
  const _ShimmerBoxGroup();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBox(width: 70, height: 18, radius: 4),
        SizedBox(height: 8),
        _ShimmerBox(width: 100, height: 12, radius: 4),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Lightweight shimmer effect with no external dependency — sweeps a
/// gradient highlight across its child on a loop.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              colors: const [
                _Palette.skeletonBase,
                _Palette.skeletonHighlight,
                _Palette.skeletonBase,
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 - t * 2, 0),
              end: Alignment(1 - t * 2, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}