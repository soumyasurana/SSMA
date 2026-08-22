import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/dashboard_service.dart';
import 'package:ssma/services/dashboard_models.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;
import 'package:ssma/widgets/sync_indicator.dart';

// Drawer Navigation Screens
import 'package:ssma/screens/supplier_screen.dart';
import 'package:ssma/screens/godown_stock_screen.dart';
import 'package:ssma/screens/report_screen.dart';
import 'package:ssma/screens/sync_settings_screen_v2.dart';

// Dashboard Components
import 'package:ssma/widgets/dashboard/kpi_card.dart';
import 'package:ssma/widgets/dashboard/section_header.dart';
import 'package:ssma/widgets/dashboard/sales_chart.dart';
import 'package:ssma/widgets/dashboard/profit_chart.dart';
import 'package:ssma/widgets/dashboard/payment_pie_chart.dart';
import 'package:ssma/widgets/dashboard/top_products_section.dart';
import 'package:ssma/widgets/dashboard/recent_transactions_section.dart';
import 'package:ssma/widgets/dashboard/alerts_section.dart';
import 'package:ssma/widgets/dashboard/quick_actions_grid.dart';
import 'package:ssma/widgets/dashboard/inventory_health_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardDateRange _selectedRange = DashboardDateRange.today;
  DateTimeRange? _customRange;
  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _error;
  String _storeName = 'My Business';

  @override
  void initState() {
    super.initState();
    _loadStoreName();
    _fetchDashboard();
    syncV2?.statusNotifier.addListener(_onSyncChanged);
  }

  void _onSyncChanged() {
    if (mounted) {
      _fetchDashboard();
    }
  }

  @override
  void dispose() {
    syncV2?.statusNotifier.removeListener(_onSyncChanged);
    super.dispose();
  }

  Future<void> _loadStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _storeName = prefs.getString('ssma_store_name') ?? 'My Business';
      });
    }
  }

  Future<void> _saveStoreName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ssma_store_name', newName);
    if (mounted) {
      setState(() {
        _storeName = newName;
      });
    }
  }

  Future<void> _fetchDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final data = await DashboardService.getDashboardData(
        range: _selectedRange,
        customRange: _customRange,
      );
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Dashboard calculation error: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _changeDateRange(DashboardDateRange range) async {
    if (range == DashboardDateRange.custom) {
      final pickedRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
        lastDate: DateTime.now().add(const Duration(days: 30)),
      );
      if (pickedRange != null) {
        setState(() {
          _selectedRange = range;
          _customRange = pickedRange;
        });
        _fetchDashboard();
      }
    } else {
      setState(() {
        _selectedRange = range;
        _customRange = null;
      });
      _fetchDashboard();
    }
  }

  void _editStoreNameDialog() {
    final controller = TextEditingController(text: _storeName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Store Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter store name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) {
                  _saveStoreName(txt);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getDateRangeLabel() {
    final format = DateFormat('dd MMM yyyy');
    if (_dashboardData == null) return '';
    return '${format.format(_dashboardData!.startDate)} - ${format.format(_dashboardData!.endDate)}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('SSMA Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: SyncIndicator(),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey[950] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.store, color: Colors.white, size: 36),
              ),
              accountName: Text(
                _storeName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: const Text('Business Management Panel'),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.indigo),
              title: const Text('Supplier Records'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse, color: Colors.indigo),
              title: const Text('Godown Stock'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GodownStockScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.indigo),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.indigo),
              title: const Text('Sync Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncSettingsScreenV2()));
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboard,
        color: Colors.indigo,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_error!, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchDashboard,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final isWide = width > 800;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Dashboard Header
                            _buildHeader(isDark),
                            const SizedBox(height: 16),

                            // 2. Date range chips
                            _buildDateRangeSelector(isDark),
                            const SizedBox(height: 16),

                            // 3. Alerts if present
                            AlertsSection(alerts: _dashboardData!.alerts),

                            // 4. Content Area: Responsive Multi-Column
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      children: [
                                        _buildKpis(isWide),
                                        const SizedBox(height: 16),
                                        SalesChart(dataPoints: _dashboardData!.salesTrend),
                                        const SizedBox(height: 16),
                                        ProfitChart(
                                          salesPoints: _dashboardData!.salesTrend,
                                          profitPoints: _dashboardData!.profitTrend,
                                        ),
                                        const SizedBox(height: 16),
                                        RecentTransactionsSection(
                                          transactions: _dashboardData!.recentTransactions,
                                          onViewAll: () {
                                            // Handle View All navigate to Sales Screen
                                            HapticFeedback.selectionClick();
                                            // Trigger tab change by popping back or using standard nav.
                                            // Since bottom bar is tab #4, we can navigate directly.
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        QuickActionsGrid(onRefreshNeeded: _fetchDashboard),
                                        const SizedBox(height: 16),
                                        PaymentPieChart(breakdown: _dashboardData!.paymentBreakdown),
                                        const SizedBox(height: 16),
                                        InventoryHealthSection(
                                          totalItems: _dashboardData!.totalInventoryItems,
                                          totalQuantity: _dashboardData!.totalInventoryQuantity,
                                          estimatedValue: _dashboardData!.estimatedInventoryValue,
                                          lowStockCount: _dashboardData!.lowStockItemCount,
                                          outOfStockCount: _dashboardData!.outOfStockItemCount,
                                          lowStockProducts: _dashboardData!.lowStockProducts,
                                        ),
                                        const SizedBox(height: 16),
                                        TopProductsSection(products: _dashboardData!.topProducts),
                                        const SizedBox(height: 16),
                                        _buildOutstandingOverview(isDark),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildKpis(isWide),
                                  const SizedBox(height: 16),
                                  SalesChart(dataPoints: _dashboardData!.salesTrend),
                                  const SizedBox(height: 16),
                                  ProfitChart(
                                    salesPoints: _dashboardData!.salesTrend,
                                    profitPoints: _dashboardData!.profitTrend,
                                  ),
                                  const SizedBox(height: 16),
                                  PaymentPieChart(breakdown: _dashboardData!.paymentBreakdown),
                                  const SizedBox(height: 16),
                                  InventoryHealthSection(
                                    totalItems: _dashboardData!.totalInventoryItems,
                                    totalQuantity: _dashboardData!.totalInventoryQuantity,
                                    estimatedValue: _dashboardData!.estimatedInventoryValue,
                                    lowStockCount: _dashboardData!.lowStockItemCount,
                                    outOfStockCount: _dashboardData!.outOfStockItemCount,
                                    lowStockProducts: _dashboardData!.lowStockProducts,
                                  ),
                                  const SizedBox(height: 16),
                                  TopProductsSection(products: _dashboardData!.topProducts),
                                  const SizedBox(height: 16),
                                  _buildOutstandingOverview(isDark),
                                  const SizedBox(height: 16),
                                  RecentTransactionsSection(
                                    transactions: _dashboardData!.recentTransactions,
                                  ),
                                  const SizedBox(height: 16),
                                  QuickActionsGrid(onRefreshNeeded: _fetchDashboard),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _storeName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.blueGrey[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16, color: Colors.indigo),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _editStoreNameDialog,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${_getGreeting()} • ${_getDateRangeLabel()}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRangeChip(DashboardDateRange.today, 'Today', isDark),
          _buildRangeChip(DashboardDateRange.thisWeek, 'This Week', isDark),
          _buildRangeChip(DashboardDateRange.thisMonth, 'This Month', isDark),
          _buildRangeChip(DashboardDateRange.thisYear, 'This Year', isDark),
          _buildRangeChip(DashboardDateRange.custom, 'Custom Range...', isDark),
        ],
      ),
    );
  }

  Widget _buildRangeChip(DashboardDateRange range, String label, bool isDark) {
    final isSelected = _selectedRange == range;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) _changeDateRange(range);
        },
        selectedColor: Colors.indigo,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.blueGrey[700]),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Colors.indigo
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  Widget _buildKpis(bool isWide) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: isWide ? 1.45 : 1.15,
      children: [
        KpiCard(
          title: 'Total Sales',
          value: currencyFormat.format(_dashboardData!.totalSales),
          subtitle: '${_dashboardData!.salesCount} Bills • Avg ${currencyFormat.format(_dashboardData!.averageBillValue)}',
          icon: Icons.attach_money,
          changePercentage: _dashboardData!.salesChangePercentage,
          changeLabel: 'vs last period',
        ),
        KpiCard(
          title: 'Gross Profit',
          value: currencyFormat.format(_dashboardData!.grossProfit),
          subtitle: 'Margin: ${_dashboardData!.profitMargin.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          iconColor: Colors.green,
          iconBgColor: Colors.green.withValues(alpha: 0.1),
          changePercentage: _dashboardData!.profitChangePercentage,
          changeLabel: 'vs last period',
        ),
        KpiCard(
          title: 'Total Purchases',
          value: currencyFormat.format(_dashboardData!.totalPurchases),
          subtitle: '${_dashboardData!.purchasesCount} Transactions',
          icon: Icons.shopping_bag_outlined,
          iconColor: Colors.red,
          iconBgColor: Colors.red.withValues(alpha: 0.1),
        ),
        KpiCard(
          title: 'Receivables Dues',
          value: currencyFormat.format(_dashboardData!.receivablesTotal),
          subtitle: '${_dashboardData!.receivablesCustomerCount} Customers pending',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: Colors.orange,
          iconBgColor: Colors.orange.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildOutstandingOverview(bool isDark) {
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
            Text(
              'Credit & Outstandings Balance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receivables
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECEIVABLES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(_dashboardData!.receivablesTotal),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_dashboardData!.topReceivables.isEmpty)
                        Text(
                          'No pending dues',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        )
                      else
                        ..._dashboardData!.topReceivables.map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.customerName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    currencyFormat.format(c.outstandingAmount),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey[600] : Colors.blueGrey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Payables
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAYABLES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(_dashboardData!.payablesTotal),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_dashboardData!.topPayables.isEmpty)
                        Text(
                          'No outstanding payables',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        )
                      else
                        ..._dashboardData!.topPayables.map((s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.supplierName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    currencyFormat.format(s.outstandingAmount),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey[600] : Colors.blueGrey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    ],
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
