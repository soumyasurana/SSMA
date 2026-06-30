import 'package:flutter/material.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/services/db_service.dart';

import 'low_stock_screen.dart';
import 'supplier_screen.dart';
import 'report_screen.dart';
import 'package:ssma/widgets/sync_indicator.dart';
import 'package:ssma/screens/sync_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalSales = 0, inMoney = 0, profit = 0;
  bool _showProfit = false;
  int totalCustomers = 0, lowStockCount = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final List<Sale> sales = await DBService.getAllSales();
    final products = await DBService.getProducts();
    final customers = await DBService.getCustomers();

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    double todaySales = 0;
    double cashReceived = 0;
    double totalCost = 0;

    for (var sale in sales) {
      final saleDate =
          DateTime(sale.date.year, sale.date.month, sale.date.day);

      if (saleDate == todayOnly) {
        todaySales += sale.totalAmount;
        cashReceived += sale.amountReceived;

        for (var item in sale.items) {
          totalCost += item.purchasePrice * item.quantity;
        }
      }
    }

    setState(() {
      totalSales = todaySales;
      inMoney = cashReceived;
      profit = todaySales - totalCost;
      totalCustomers = customers.length;
      lowStockCount = products.where((p) => p.quantity < 5).length;
    });
  }

  Widget buildCard({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
    VoidCallback? onTap,
  }) {
    final card = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color ?? Colors.indigo,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 18)),
      ),
    );

    return onTap != null ? InkWell(onTap: onTap, child: card) : card;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.indigo,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          SyncIndicator(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Supplier Records'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupplierScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Settings'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SyncSettingsScreen()),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildCard(
                icon: Icons.attach_money,
                label: 'Total Sales Today',
                value: '₹${totalSales.toStringAsFixed(2)}',
                color: Colors.green,
              ),
              buildCard(
                icon: Icons.payments,
                label: 'Cash Received Today',
                value: '₹${inMoney.toStringAsFixed(2)}',
                color: Colors.teal,
              ),
              buildCard(
                icon: Icons.people,
                label: 'Total Customers',
                value: totalCustomers.toString(),
                color: Colors.blue,
              ),
              buildCard(
                icon: Icons.warning,
                label: 'Low Stock Products',
                value: lowStockCount.toString(),
                color: Colors.redAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LowStockScreen()),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showProfit = !_showProfit),
                icon: Icon(
                    _showProfit ? Icons.visibility_off : Icons.visibility),
                label: Text(_showProfit ? 'Hide Profit' : 'Show Profit'),
              ),
              if (_showProfit)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: buildCard(
                    icon: Icons.trending_up,
                    label: 'Profit Today',
                    value: '₹${profit.toStringAsFixed(2)}',
                    color: Colors.deepPurple,
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
