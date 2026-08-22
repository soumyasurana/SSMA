import 'package:flutter/material.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/utils/search_utils.dart';

class GodownStockScreen extends StatefulWidget {
  const GodownStockScreen({super.key});

  @override
  State<GodownStockScreen> createState() => _GodownStockScreenState();
}

class _GodownStockScreenState extends State<GodownStockScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await DBService.getProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _filteredProducts = products;
      _loading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = SearchUtils.fuzzySort<Product>(
        _products,
        _searchController.text,
        (product) => product.name,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Godown Stock'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.amber.shade100,
            child: const Text(
              'Reference stock list only. Creating bills elsewhere will not be triggered from this view, and opening this list never deducts godown stock.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search godown items',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: _filteredProducts.isEmpty
                        ? const Center(child: Text('No stock found.'))
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: _filteredProducts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.indigo.shade50,
                                    child: const Icon(Icons.warehouse,
                                        color: Colors.indigo),
                                  ),
                                  title: Text(product.name),
                                  subtitle: Text(
                                    'Buy ₹${product.purchasePrice.toStringAsFixed(2)} | Sell ₹${product.salePrice.toStringAsFixed(2)}',
                                  ),
                                  trailing: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minWidth: 72),
                                    child: Text(
                                      product.quantity.toString(),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
