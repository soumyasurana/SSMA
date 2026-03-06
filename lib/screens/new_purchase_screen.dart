import 'package:flutter/material.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/purchase_item.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';

class NewPurchaseScreen extends StatefulWidget {
  final Supplier supplier;

  const NewPurchaseScreen({super.key, required this.supplier});

  @override
  State<NewPurchaseScreen> createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends State<NewPurchaseScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final List<PurchaseItem> _items = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();

  late String deviceId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    deviceId = await DeviceService.getDeviceId();
    await _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _loadProducts() async {
    final list = await DBService.getProducts();
    setState(() {
      _products = list.where((p) => !p.deleted).toList();
      _filteredProducts = _products;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts =
          _products.where((p) => p.name.toLowerCase().contains(query)).toList();
    });
  }

  void _addOrEditItem({required Product product, PurchaseItem? existing}) {
    final qtyController =
        TextEditingController(text: existing?.quantity.toString() ?? '');
    final priceController = TextEditingController(
        text: existing?.purchasePrice.toString() ??
            product.purchasePrice.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${existing != null ? "Edit" : "Add"} ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Purchase Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(qtyController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0;

              if (quantity <= 0 || price <= 0) return;

              setState(() {
                if (existing != null) {
                  existing.quantity = quantity;
                  existing.purchasePrice = price;
                  existing.total = quantity * price;
                  existing.updatedAt = DateTime.now();
                  existing.version += 1;
                  existing.isSynced = false;
                } else {
                  _items.add(PurchaseItem.create(
                    productUuid: product.uuid,
                    productName: product.name,
                    purchasePrice: price,
                    quantity: quantity,
                    deviceId: deviceId,
                  ));
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  double get total =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  Future<void> _savePurchase() async {
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final purchase = Purchase.create(
      supplierUuid: widget.supplier.uuid,
      purchaseItems: _items,
      totalAmount: total,
      date: DateTime.now(),
      deviceId: deviceId,
      amountPaid: amountPaid,
      note: _noteController.text,
    );

    await DBService.addPurchase(purchase);

    // DBService.addPurchase already adjusts stock quantities.
    // Only refresh purchase price metadata here.
    for (final item in _items) {
      final product = _products.firstWhere((p) => p.uuid == item.productUuid);

      product.purchasePrice = item.purchasePrice;
      product.updatedAt = DateTime.now();
      product.version += 1;
      product.isSynced = false;

      await DBService.updateProduct(product);
    }

    // Supplier payment
    if (amountPaid > 0) {
      final payment = SupplierPayment.create(
        supplierUuid: widget.supplier.uuid,
        amount: amountPaid,
        date: DateTime.now(),
        note: "Payment during purchase",
        deviceId: deviceId,
      );

      await DBService.addSupplierPayment(payment);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    _noteController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Purchase - ${widget.supplier.name}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  const Text('Select Product to Add:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filteredProducts
                        .map((p) => ElevatedButton(
                              onPressed: () =>
                                  _addOrEditItem(product: p),
                              child: Text(p.name),
                            ))
                        .toList(),
                  ),
                  const Divider(height: 30),
                  const Text('Selected Items:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._items.map((item) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(item.productName),
                        subtitle: Text(
                            '${item.quantity} × ₹${item.purchasePrice.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                final product = _products.firstWhere(
                                    (p) => p.uuid == item.productUuid);
                                _addOrEditItem(
                                    product: product, existing: item);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() => _items.remove(item));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const Divider(),
                  ListTile(
                    title: const Text('Total Amount'),
                    trailing:
                        Text('₹${total.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountPaidController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount Paid Now (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                        labelText: 'Note (optional)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _savePurchase,
              icon: const Icon(Icons.save),
              label: const Text('Save Purchase'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
