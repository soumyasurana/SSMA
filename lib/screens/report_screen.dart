import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssma/services/pdf_service.dart';
import 'package:ssma/services/report_models.dart';
import 'package:ssma/services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ReportTimePreset _selectedPreset = ReportTimePreset.thisMonth;
  DateTimeRange? _customDateRange;

  bool _loading = true;
  String? _errorMessage;
  BusinessReportData? _reportData;

  // Search & Filter controllers
  final TextEditingController _productSearchController =
      TextEditingController();
  final TextEditingController _customerSearchController =
      TextEditingController();
  final TextEditingController _supplierSearchController =
      TextEditingController();

  String _productSortBy = 'Revenue'; // 'Revenue', 'Profit', 'Quantity'
  String _customerSortBy = 'Revenue'; // 'Revenue', 'Outstanding'

  final NumberFormat _currencyFmt =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productSearchController.dispose();
    _customerSearchController.dispose();
    _supplierSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      DateTimeRange range;
      if (_selectedPreset == ReportTimePreset.custom &&
          _customDateRange != null) {
        range = _customDateRange!;
      } else {
        range = ReportService.getPresetRange(_selectedPreset);
      }

      final label = _selectedPreset == ReportTimePreset.custom
          ? '${_dateFmt.format(range.start)} – ${_dateFmt.format(range.end)}'
          : ReportService.getPresetLabel(_selectedPreset);

      final data = await ReportService.generateReport(
        startDate: range.start,
        endDate: range.end,
        presetLabel: label,
      );

      if (mounted) {
        setState(() {
          _reportData = data;
          _loading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('ReportScreen Error: $e\n$stack');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to generate report: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = ReportTimePreset.custom;
        _customDateRange = picked;
      });
      _loadReportData();
    }
  }

  Future<void> _exportPdf() async {
    if (_reportData == null) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating Executive Report PDF...')),
      );
      await PDFService.generateExecutiveReportPdf(_reportData!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Business Intelligence',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Financial & Operational Bible',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export Executive PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: _loading ? null : _exportPdf,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _loadReportData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_rounded, size: 18), text: 'P&L & Cash Flow'),
            Tab(icon: Icon(Icons.point_of_sale_rounded, size: 18), text: 'Sales Analytics'),
            Tab(icon: Icon(Icons.warehouse_rounded, size: 18), text: 'Inventory & Godown'),
            Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: 'Customers & Credit'),
            Tab(icon: Icon(Icons.local_shipping_rounded, size: 18), text: 'Suppliers & Payables'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTimeFilterBar(isDark),
          Expanded(
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Analyzing business metrics...',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(_errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadReportData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                              )
                            ],
                          ),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPnLCashFlowTab(isDark),
                          _buildSalesAnalyticsTab(isDark),
                          _buildInventoryGodownTab(isDark),
                          _buildCustomersCreditTab(isDark),
                          _buildSuppliersPayablesTab(isDark),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  // ─── Preset Time Filter Bar ────────────────────────────────────────────────
  Widget _buildTimeFilterBar(bool isDark) {
    const presets = ReportTimePreset.values;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.indigo.shade800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: presets.map((preset) {
                final isSelected = _selectedPreset == preset;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      ReportService.getPresetLabel(preset),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.black87
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.amberAccent,
                    backgroundColor: Colors.white.withOpacity(0.12),
                    checkmarkColor: Colors.black87,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? Colors.amberAccent : Colors.white24,
                      ),
                    ),
                    onSelected: (_) {
                      if (preset == ReportTimePreset.custom) {
                        _pickCustomDateRange();
                      } else {
                        setState(() => _selectedPreset = preset);
                        _loadReportData();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (_reportData != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_dateFmt.format(_reportData!.startDate)} – ${_dateFmt.format(_reportData!.endDate)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: _pickCustomDateRange,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: Colors.amberAccent),
                        SizedBox(width: 4),
                        Text('Change Range',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: P&L & CASH FLOW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPnLCashFlowTab(bool isDark) {
    final d = _reportData!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top 4 Primary KPI Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Gross Revenue',
                value: _currencyFmt.format(d.grossSales),
                subtitle: '${d.totalOrders} Orders • ${_currencyFmt.format(d.averageOrderValue)} AOV',
                icon: Icons.payments_rounded,
                color: Colors.blue,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Cost of Goods (COGS)',
                value: _currencyFmt.format(d.cogs),
                subtitle: '${d.totalItemsSold} Units Sold',
                icon: Icons.shopping_bag_rounded,
                color: Colors.deepOrange,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Gross Profit',
                value: _currencyFmt.format(d.grossProfit),
                subtitle: '${d.profitMarginPercentage.toStringAsFixed(1)}% Gross Margin',
                icon: Icons.trending_up_rounded,
                color: d.grossProfit >= 0 ? Colors.green : Colors.red,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Net Cash Flow',
                value: _currencyFmt.format(d.netCashFlow),
                subtitle: 'Inflow − Outflow',
                icon: Icons.account_balance_wallet_rounded,
                color: d.netCashFlow >= 0 ? Colors.teal : Colors.orange,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // P&L Statement Card
        _buildSectionCard(
          title: 'Profit & Loss Statement',
          icon: Icons.receipt_long_rounded,
          isDark: isDark,
          child: Column(
            children: [
              _buildStatementRow('Gross Sales Turnover', d.grossSales, isBold: true),
              _buildStatementRow('Less: Cost of Goods Sold (COGS)', -d.cogs, color: Colors.red.shade700),
              const Divider(),
              _buildStatementRow(
                'Gross Realized Profit',
                d.grossProfit,
                isBold: true,
                color: d.grossProfit >= 0 ? Colors.green.shade700 : Colors.red,
                trailingBadge: '${d.profitMarginPercentage.toStringAsFixed(1)}% Margin',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniBadge('Cash Sales', _currencyFmt.format(d.cashSalesTotal), Colors.green),
                    _buildMiniBadge('Credit Sales', _currencyFmt.format(d.creditSalesTotal), Colors.orange),
                    _buildMiniBadge('Unpaid Credit Added', _currencyFmt.format(d.periodCustomerReceivablesAdded), Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Cash Flow Liquidity Analysis
        _buildSectionCard(
          title: 'Cash Flow & Liquidity Generation',
          icon: Icons.swap_horiz_rounded,
          isDark: isDark,
          child: Column(
            children: [
              _buildStatementRow('Sales Counter Collections', d.salesCashCollected),
              _buildStatementRow('Customer Dues Recovered', d.customerReceiptsCollected),
              const Divider(),
              _buildStatementRow('Total Cash Inflow', d.totalCashInflow, isBold: true, color: Colors.green.shade700),
              const SizedBox(height: 6),
              _buildStatementRow('Supplier Purchases Payments Paid', -d.supplierPaymentsPaid, color: Colors.red.shade700),
              const Divider(),
              _buildStatementRow('Net Cash Generation', d.netCashFlow,
                  isBold: true,
                  color: d.netCashFlow >= 0 ? Colors.teal.shade700 : Colors.red.shade700),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Working Capital Position
        _buildSectionCard(
          title: 'Working Capital & Dues Overview',
          icon: Icons.balance_rounded,
          isDark: isDark,
          child: Column(
            children: [
              _buildStatementRow('Total Customer Receivables (Dues)', d.totalCustomerReceivables, color: Colors.orange.shade800),
              _buildStatementRow('Total Supplier Payables (Unpaid)', d.totalSupplierPayables, color: Colors.purple.shade700),
              const Divider(),
              _buildStatementRow(
                'Net Working Position (Receivables − Payables)',
                d.netWorkingCapitalPosition,
                isBold: true,
                color: d.netWorkingCapitalPosition >= 0 ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment Method Mix
        if (d.paymentMethods.isNotEmpty)
          _buildSectionCard(
            title: 'Payment Methods Breakdown',
            icon: Icons.pie_chart_rounded,
            isDark: isDark,
            child: Column(
              children: d.paymentMethods.map((pm) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(pm.method,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            '${_currencyFmt.format(pm.amount)} (${pm.percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pm.percentage / 100,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pm.method.toLowerCase().contains('upi')
                                ? Colors.deepPurple
                                : pm.method.toLowerCase().contains('cash')
                                    ? Colors.green
                                    : Colors.blue,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: SALES & PRODUCT ANALYTICS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSalesAnalyticsTab(bool isDark) {
    final d = _reportData!;

    List<ProductReportItem> filteredProducts;
    if (_productSortBy == 'Profit') {
      filteredProducts = List.from(d.topProductsByProfit);
    } else if (_productSortBy == 'Quantity') {
      filteredProducts = List.from(d.topProductsByQuantity);
    } else {
      filteredProducts = List.from(d.topProductsByRevenue);
    }

    final query = _productSearchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => p.productName.toLowerCase().contains(query))
          .toList();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sales Mix & Order Metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Cash Sales Share',
                value: '${d.cashSalesRatio.toStringAsFixed(1)}%',
                subtitle: _currencyFmt.format(d.cashSalesTotal),
                icon: Icons.money_rounded,
                color: Colors.green,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Credit Sales Share',
                value: '${d.creditSalesRatio.toStringAsFixed(1)}%',
                subtitle: _currencyFmt.format(d.creditSalesTotal),
                icon: Icons.credit_score_rounded,
                color: Colors.orange,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Product Rankings Header & Controls
        _buildSectionCard(
          title: 'Product Performance & Unit Economics',
          icon: Icons.inventory_2_rounded,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _productSearchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _productSortBy,
                    items: const [
                      DropdownMenuItem(value: 'Revenue', child: Text('By Revenue')),
                      DropdownMenuItem(value: 'Profit', child: Text('By Profit')),
                      DropdownMenuItem(value: 'Quantity', child: Text('By Quantity')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _productSortBy = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (filteredProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No product sales recorded in this period.',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...filteredProducts.map((p) => _buildProductReportTile(p, isDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductReportTile(ProductReportItem p, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.indigo.withOpacity(0.12),
            child: Text(
              p.productName.isNotEmpty ? p.productName[0].toUpperCase() : 'P',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '${p.quantitySold} units sold • Stock remaining: ${p.currentStock}',
                  style: TextStyle(
                    fontSize: 11,
                    color: p.currentStock <= 5 ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_currencyFmt.format(p.revenue),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                'Profit: ${_currencyFmt.format(p.profit)} (${p.marginPercentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.profit >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: INVENTORY & GODOWN VALUATION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInventoryGodownTab(bool isDark) {
    final d = _reportData!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Shop Inventory Valuation Card
        _buildSectionCard(
          title: 'Shop Inventory Valuation',
          icon: Icons.storefront_rounded,
          isDark: isDark,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatBox('Valuation (Cost)', _currencyFmt.format(d.shopInventoryValuationAtCost), Colors.blue, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStatBox('Retail Value', _currencyFmt.format(d.shopInventoryValuationAtRetail), Colors.indigo, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatBox('Potential Profit in Stock', _currencyFmt.format(d.potentialInventoryProfit), Colors.green, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStatBox('Total Units in Shop', '${d.totalShopStockUnits} units', Colors.teal, isDark),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Godown Stock Valuation Card
        _buildSectionCard(
          title: 'Godown Bulk Storage Valuation',
          icon: Icons.warehouse_rounded,
          isDark: isDark,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatBox('Godown Valuation (Cost)', _currencyFmt.format(d.godownInventoryValuationAtCost), Colors.amber.shade800, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStatBox('Total Units in Godown', '${d.totalGodownStockUnits} units', Colors.orange, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatBox('Godown to Shop Transfers', '${d.godownTransfersToShopUnits} units', Colors.deepPurple, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStatBox('Movements in Period', '${d.totalGodownMovementsInPeriod} logs', Colors.blueGrey, isDark),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stock Health & Warnings
        _buildSectionCard(
          title: 'Stock Health & Risk Alerts',
          icon: Icons.warning_amber_rounded,
          isDark: isDark,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniBadge('Low Stock (≤5)', '${d.lowStockCount} items', Colors.orange),
                  _buildMiniBadge('Out of Stock', '${d.outOfStockCount} items', Colors.red),
                  _buildMiniBadge('Non-Moving (Dead)', '${d.deadOrLowMovingProducts.length} items', Colors.purple),
                ],
              ),
              if (d.deadOrLowMovingProducts.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Top Non-Moving / Dead Stock Items in Period:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 8),
                ...d.deadOrLowMovingProducts.take(5).map(
                      (p) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.purple),
                        title: Text(p.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        trailing: Text('${p.currentStock} units in stock',
                            style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold)),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 4: CUSTOMERS & CREDIT RECEIVABLES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCustomersCreditTab(bool isDark) {
    final d = _reportData!;

    List<CustomerReportItem> filteredCustomers;
    if (_customerSortBy == 'Outstanding') {
      filteredCustomers = List.from(d.topCustomersByOutstanding);
    } else {
      filteredCustomers = List.from(d.topCustomersByRevenue);
    }

    final query = _customerSearchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filteredCustomers = filteredCustomers
          .where((c) =>
              c.customerName.toLowerCase().contains(query) ||
              (c.phone != null && c.phone!.contains(query)))
          .toList();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Outstanding Dues',
                value: _currencyFmt.format(d.totalCustomerReceivables),
                subtitle: 'Active market receivables',
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.orange,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Period Credit Extended',
                value: _currencyFmt.format(d.periodCustomerReceivablesAdded),
                subtitle: 'Unpaid bills in period',
                icon: Icons.add_circle_outline_rounded,
                color: Colors.red,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionCard(
          title: 'Customer Accounts & Ledger Summary',
          icon: Icons.people_rounded,
          isDark: isDark,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customerSearchController,
                      decoration: InputDecoration(
                        hintText: 'Search customer name or phone...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _customerSortBy,
                    items: const [
                      DropdownMenuItem(value: 'Revenue', child: Text('By Billed')),
                      DropdownMenuItem(value: 'Outstanding', child: Text('By Dues')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _customerSortBy = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (filteredCustomers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No customers found.',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...filteredCustomers.map((c) => _buildCustomerReportTile(c, isDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerReportTile(CustomerReportItem c, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.withOpacity(0.12),
            child: Text(
              c.customerName.isNotEmpty ? c.customerName[0].toUpperCase() : 'C',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if (c.phone != null && c.phone!.isNotEmpty)
                  Text(c.phone!, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text(
                  '${c.orderCount} orders • Billed: ${_currencyFmt.format(c.totalBilled)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Due: ${_currencyFmt.format(c.currentOutstanding)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: c.currentOutstanding > 0 ? Colors.red : Colors.green,
                ),
              ),
              Text('Paid: ${_currencyFmt.format(c.totalPaid)}',
                  style: const TextStyle(fontSize: 11, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 5: SUPPLIERS & PAYABLES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSuppliersPayablesTab(bool isDark) {
    final d = _reportData!;

    final query = _supplierSearchController.text.trim().toLowerCase();
    var filteredSuppliers = List.from(d.topSuppliersByPurchases);
    if (query.isNotEmpty) {
      filteredSuppliers = filteredSuppliers
          .where((s) =>
              s.supplierName.toLowerCase().contains(query) ||
              (s.phone != null && s.phone!.contains(query)))
          .toList();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Supplier Payables',
                value: _currencyFmt.format(d.totalSupplierPayables),
                subtitle: 'Total unpaid stock balances',
                icon: Icons.local_shipping_rounded,
                color: Colors.purple,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Period Payments Paid',
                value: _currencyFmt.format(d.supplierPaymentsPaid),
                subtitle: 'Paid to suppliers in period',
                icon: Icons.check_circle_outline_rounded,
                color: Colors.teal,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionCard(
          title: 'Supplier Accounts & Payables Ledger',
          icon: Icons.business_rounded,
          isDark: isDark,
          child: Column(
            children: [
              TextField(
                controller: _supplierSearchController,
                decoration: InputDecoration(
                  hintText: 'Search supplier name or contact...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              if (filteredSuppliers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No suppliers found.',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...filteredSuppliers.map((s) => _buildSupplierReportTile(s, isDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierReportTile(SupplierReportItem s, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.purple.withOpacity(0.12),
            child: Text(
              s.supplierName.isNotEmpty ? s.supplierName[0].toUpperCase() : 'S',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.supplierName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if (s.phone != null && s.phone!.isNotEmpty)
                  Text(s.phone!, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text(
                  '${s.purchaseCount} purchases in period',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Due: ${_currencyFmt.format(s.currentBalanceDue)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: s.currentBalanceDue > 0 ? Colors.red : Colors.green,
                ),
              ),
              Text('Purchased: ${_currencyFmt.format(s.totalPurchased)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED REUSABLE UI WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStatementRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
    String? trailingBadge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (trailingBadge != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                trailingBadge,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          Text(
            _currencyFmt.format(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatBox(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
