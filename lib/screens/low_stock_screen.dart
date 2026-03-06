import 'package:flutter/material.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/services/db_service.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  List<Product> _allProducts = [];
  List<Product> _lowStockProducts = [];
  int _stockThreshold = 5;

  @override
  void initState() {
    super.initState();
    loadLowStock();
  }

  Future<void> loadLowStock() async {
    final products = await DBService.getProducts();

    setState(() {
      // Exclude soft-deleted products
      _allProducts = products.where((p) => !p.deleted).toList();
      _filterLowStock();
    });
  }

  void _filterLowStock() {
    _lowStockProducts = _allProducts
        .where((p) => p.quantity < _stockThreshold)
        .toList();
  }

  Future<void> _refresh() async {
    await loadLowStock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Items'),
        backgroundColor: Colors.redAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _stockThreshold,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                dropdownColor: Colors.white,
                items: const [3, 5, 10, 15].map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('Stock < $value'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _stockThreshold = value;
                      _filterLowStock();
                    });
                  }
                },
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _lowStockProducts.isEmpty
            ? const Center(
                child: Text(
                  '🎉 No low stock items under current filter!',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _lowStockProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = _lowStockProducts[index];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orangeAccent,
                        size: 32,
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        'Qty Left: ${product.quantity}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Selling Price',
                              style: TextStyle(fontSize: 12)),
                          Text(
                            '₹${product.salePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
