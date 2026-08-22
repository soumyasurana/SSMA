import 'package:flutter/material.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart'; // <-- for deviceId
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;
import 'package:ssma/utils/search_utils.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';

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
    syncV2?.statusNotifier.addListener(_onSyncChanged);
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

  void _onSyncChanged() {
    if (mounted) {
      _loadProducts();
    }
  }

  @override
  void dispose() {
    syncV2?.statusNotifier.removeListener(_onSyncChanged);
    _searchController.dispose();
    _nameController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
  // ===================== EXCEL IMPORT =====================

  Future<void> _importExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;

    if (file.path == null) return;

    final bytes = await File(file.path!).readAsBytes();

    await _processExcel(bytes);
  }

  Future<void> _processExcel(Uint8List bytes) async {
    final excel = Excel.decodeBytes(bytes);
    final deviceId = await DeviceService.getDeviceId();

    int success = 0;
    int failed = 0;

    for (var table in excel.tables.keys) {
      final rows = excel.tables[table]!.rows;

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        try {
          final name = row[0]?.value?.toString().trim() ?? '';
          final purchasePrice =
              double.tryParse(row[1]?.value.toString() ?? '') ?? 0;
          final salePrice =
              double.tryParse(row[2]?.value.toString() ?? '') ?? 0;
          final quantity = int.tryParse(row[3]?.value.toString() ?? '') ?? 0;

          // SAME VALIDATION (unchanged logic)
          if (name.isEmpty || purchasePrice < 0 || salePrice < 0) {
            failed++;
            continue;
          }

          // SAME DUPLICATE CHECK (unchanged logic)
          final exists = _products
              .where((p) => p.name.toLowerCase() == name.toLowerCase());

          if (exists.isNotEmpty) {
            failed++;
            continue;
          }

          final product = Product.create(
            name: name,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            quantity: quantity,
            deviceId: deviceId,
          );

          await DBService.addProduct(product);
          success++;
        } catch (e) {
          failed++;
        }
      }
    }

    await _loadProducts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Import complete: $success added, $failed failed'),
      ),
    );
  }

  Future<void> _loadProducts() async {
    final products = await DBService.getProducts();
    final query = _searchController.text;
    setState(() {
      _products = products;
      _filteredProducts = query.isEmpty
          ? products
          : SearchUtils.fuzzySort<Product>(
              products,
              query,
              (p) => p.name,
            );
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = query.isEmpty
          ? _products
          : SearchUtils.fuzzySort<Product>(
              _products,
              query,
              (p) => p.name,
            );
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
                        content: Text(
                            'Enter valid prices and a non-negative quantity.')),
                  );
                  return;
                }

                final currentProductUuid = isEdit ? product.uuid : '';

                // Prevent duplicate product names (case-insensitive)
                final existing = _products.where((p) =>
                    p.name.toLowerCase() == name.toLowerCase() &&
                    (!isEdit || p.uuid != currentProductUuid));
                if (existing.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('A product with this name already exists.')),
                  );
                  return;
                }

                if (isEdit) {
                  final editingProduct = product;
                  editingProduct
                    ..name = name
                    ..purchasePrice = purchasePrice
                    ..salePrice = salePrice
                    ..quantity = quantity;
                  // NOTE: Do NOT set updatedAt/isSynced/version here.
                  // DBService.updateProduct handles all sync bookkeeping.
                  await DBService.updateProduct(editingProduct);
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

                if (!context.mounted) return;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              await DBService.deleteProduct(product.uuid);

              if (!context.mounted) return;
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
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadProducts();
                await syncV2?.syncManager.syncWithAllPeers();
              },
              child: _filteredProducts.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child:
                            const Center(child: Text('No matching products.')),
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _importExcel,
            icon: const Icon(Icons.upload_file),
            label: const Text('Import'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () => _showProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }
}
