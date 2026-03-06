import 'package:flutter/material.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart'; // <-- for deviceId

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  final _nameController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await DBService.getProducts();
    setState(() {
      _products = products;
      _filteredProducts = products;
    });
  }

  void _filterProducts(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredProducts =
          _products.where((p) => p.name.toLowerCase().contains(q)).toList();
    });
  }

  void _showProductDialog({Product? product}) async {
    final isEdit = product != null;

    if (isEdit) {
      _nameController.text = product.name;
      _purchasePriceController.text = product.purchasePrice.toString();
      _salePriceController.text = product.salePrice.toString();
      _quantityController.text = product.quantity.toString();
    } else {
      _nameController.clear();
      _purchasePriceController.clear();
      _salePriceController.clear();
      _quantityController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'Edit Product' : 'Add Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_nameController, 'Product Name'),
                const SizedBox(height: 10),
                _buildTextField(_purchasePriceController, 'Purchase Price',
                    isNumber: true),
                const SizedBox(height: 10),
                _buildTextField(_salePriceController, 'Sale Price',
                    isNumber: true),
                const SizedBox(height: 10),
                _buildTextField(_quantityController, 'Quantity',
                    isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: Icon(isEdit ? Icons.save : Icons.add),
              label: Text(isEdit ? 'Update' : 'Add'),
              onPressed: () async {
                final name = _nameController.text.trim();
                final purchasePrice =
                    double.tryParse(_purchasePriceController.text.trim()) ?? 0;
                final salePrice =
                    double.tryParse(_salePriceController.text.trim()) ?? 0;
                final quantity =
                    int.tryParse(_quantityController.text.trim()) ?? 0;

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product name is required.')),
                  );
                  return;
                }

                if (purchasePrice <= 0 || salePrice <= 0 || quantity < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Enter valid prices and a non-negative quantity.')),
                  );
                  return;
                }

                // Prevent duplicate product names (case-insensitive)
                final existing = _products.where((p) =>
                    p.name.toLowerCase() == name.toLowerCase() &&
                    (!isEdit || p.uuid != product!.uuid));
                if (existing.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('A product with this name already exists.')),
                  );
                  return;
                }

                if (isEdit) {
                  product!
                    ..name = name
                    ..purchasePrice = purchasePrice
                    ..salePrice = salePrice
                    ..quantity = quantity
                    ..updatedAt = DateTime.now()
                    ..isSynced = false
                    ..version += 1;

                  await DBService.updateProduct(product);
                } else {
                  final deviceId = await DeviceService.getDeviceId();

                  final newProduct = Product.create(
                    name: name,
                    purchasePrice: purchasePrice,
                    salePrice: salePrice,
                    quantity: quantity,
                    deviceId: deviceId,
                  );

                  await DBService.addProduct(newProduct);
                }

                Navigator.pop(context);
                _loadProducts();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete '${product.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              product.deleted = true;
              product.isSynced = false;
              product.version += 1;

              await DBService.updateProduct(product);

              Navigator.pop(context);
              _loadProducts();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No matching products.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = _filteredProducts[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        color: Colors.indigo.shade50,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          title: Text(
                            p.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Qty: ${p.quantity} | Buy: ₹${p.purchasePrice.toStringAsFixed(2)} | Sale: ₹${p.salePrice.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () =>
                                    _showProductDialog(product: p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => _confirmDelete(p),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
