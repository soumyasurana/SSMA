import 'package:flutter/material.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/sale_item.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';
import 'package:ssma/services/pdf_service.dart';

/// Minimal interface used by NewSaleScreen so tests can inject a fake.
abstract class IDBService {
  Future<List<Product>> getProducts();
  Future<List<Customer>> getCustomers();
  Future<void> recordSale(Sale sale);
  Future<void> updateProduct(Product product);
  Future<Product?> getProductByUuid(String uuid);
}

/// Adapter that delegates to your existing static DBService methods.
/// This keeps production behavior identical.
class RealDBServiceAdapter implements IDBService {
  @override
  Future<List<Product>> getProducts() => DBService.getProducts();

  @override
  Future<List<Customer>> getCustomers() => DBService.getCustomers();

  @override
  Future<void> recordSale(Sale sale) => DBService.recordSale(sale);

  @override
  Future<void> updateProduct(Product product) => DBService.updateProduct(product);

  @override
  Future<Product?> getProductByUuid(String uuid) => DBService.getProductByUuid(uuid);
}

class NewSaleScreen extends StatefulWidget {
  final Sale? existingSale;

  /// Optional dependency injection slot for tests. If null, we use the real adapter.
  final IDBService? dbService;

  const NewSaleScreen({super.key, this.existingSale, this.dbService});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Customer> _customers = [];
  List<SaleItem> _saleItems = [];

  final TextEditingController _buyerNameController = TextEditingController();
  final TextEditingController _buyerContactController = TextEditingController();
  final TextEditingController _searchProductController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountReceivedController = TextEditingController();
  final List<Map<String, TextEditingController>> _extraCharges = [];

  SaleType _selectedSaleType = SaleType.cash;
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  String _deviceId = '';
  bool _isSaving = false;
  Map<String, double> _productsToUpdatePrice = {};

  // convenience getter that returns injected service or default real adapter
  IDBService get _db => widget.dbService ?? RealDBServiceAdapter();

  @override
  void initState() {
    super.initState();
    loadData();
    _searchProductController.addListener(() {
      _filterProducts(_searchProductController.text);
    });

    if (widget.existingSale != null) {
      final sale = widget.existingSale!;
      _saleItems = List.from(sale.items);
      _buyerNameController.text = sale.buyerName ?? '';
      _buyerContactController.text = sale.buyerContact ?? '';
      _commentController.text = sale.comment ?? '';
      _amountReceivedController.text = sale.amountReceived.toString();
      _selectedDate = sale.date;
      _selectedSaleType = sale.saleType;
    }
  }

  @override
  void dispose() {
    _buyerNameController.dispose();
    _buyerContactController.dispose();
    _searchProductController.dispose();
    _commentController.dispose();
    _amountReceivedController.dispose();
    for (final charge in _extraCharges) {
      charge['key']!.dispose();
      charge['value']!.dispose();
    }
    super.dispose(); // must be last
  }

  Future<void> loadData() async {
    _deviceId = await DeviceService.getDeviceId();
    // -> now uses injected service (or real adapter)
    final products = await _db.getProducts();
    final customers = await _db.getCustomers();
    setState(() {
      _products = products;
      _filteredProducts = products;
      _customers = customers;
    });

    // Preselect customer if editing and it's a credit sale
    if (widget.existingSale != null && widget.existingSale!.saleType == SaleType.credit) {
      final match = customers.firstWhere(
        (c) =>
            c.name == widget.existingSale!.buyerName &&
            c.phone == widget.existingSale!.buyerContact,
        orElse: () => customers.isNotEmpty ? customers[0] : Customer(),
      );
      setState(() => _selectedCustomer = match);
    }
  }


  double _calculateExtraCharges() {
  return _extraCharges.fold(0.0, (sum, charge) {
    return sum + (double.tryParse(charge['value']!.text) ?? 0.0);
  });
  }

  void _filterProducts(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((p) => p.name.toLowerCase().contains(lower)).toList();
    });
  }

  void _showQuantityDialog(Product product) {
    final qtyController = TextEditingController(text: '1');
    final priceController =
        TextEditingController(text: product.salePrice.toStringAsFixed(2));
    bool updateInventoryPrice = false;

    if (product.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Warning: "${product.name}" is out of stock. Stock will go negative!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepOrange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setDialogState) => AlertDialog(
          title: Text('Add ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Sale Price'),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Update price in inventory as well'),
                value: updateInventoryPrice,
                onChanged: (val) {
                  setDialogState(() {
                    updateInventoryPrice = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(qtyController.text);
                final price = double.tryParse(priceController.text);

                if (qty != null && qty > 0 && price != null && price >= 0) {
                  if (updateInventoryPrice) {
                    _productsToUpdatePrice[product.uuid] = price;
                  }

                  if (!mounted) return;
                  setState(() {
                    _saleItems.add(
                      SaleItem.create(
                        productUuid: product.uuid,
                        productName: product.name,
                        quantity: qty,
                        unitPrice: price,
                        purchasePrice: product.purchasePrice,
                        deviceId: _deviceId,
                      ),
                    );
                  });
                }
                if (innerContext.mounted) {
                  Navigator.pop(innerContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }


  void _showCustomItemDialog() {
    final nameController = TextEditingController();
    final purchaseController = TextEditingController();
    final saleController = TextEditingController();
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Custom Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: purchaseController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Purchase Price'),
            ),
            TextField(
              controller: saleController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Sale Price'),
            ),
            TextField(
              controller: qtyController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final purchase = double.tryParse(purchaseController.text) ?? 0;
              final sale = double.tryParse(saleController.text) ?? 0;
              final qty = double.tryParse(qtyController.text) ?? 0;

              if (name.isNotEmpty && sale > 0 && qty > 0) {
                setState(() {
                  _saleItems.add(
                    SaleItem.create(
                      productUuid: '',
                      productName: name,
                      quantity: qty.toInt(),
                      unitPrice: sale,
                      purchasePrice: purchase,
                      deviceId: _deviceId,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _editItem(SaleItem item) {
    final qtyController =
        TextEditingController(text: item.quantity.toStringAsFixed(0));
    final priceController =
        TextEditingController(text: item.unitPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${item.productName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Sale Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text);
              final price = double.tryParse(priceController.text);
              if (qty != null && qty > 0 && price != null && price >= 0) {
                setState(() {
                  item.quantity = qty.toInt();
                  item.unitPrice = price;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _removeItem(SaleItem item) {
    setState(() {
      _saleItems.remove(item);
      _productsToUpdatePrice.remove(item.productUuid);
    });
  }

  double _calculateTotalAmount() {
    final itemsTotal = _saleItems.fold(0.0, (sum, item) => sum + item.unitPrice * item.quantity);
    return itemsTotal + _calculateExtraCharges();
  }

    Future<void> _completeSale() async {
    if (_isSaving) return;

    if (_saleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to complete sale.')),
      );
      return;
    }

    String buyerName = _buyerNameController.text.trim();
    String buyerContact = _buyerContactController.text.trim();

    if (_selectedSaleType == SaleType.credit && _selectedCustomer != null) {
      buyerName = _selectedCustomer!.name;
      buyerContact = _selectedCustomer!.phone ?? '';
    }

    if (_selectedSaleType == SaleType.cash &&
        (buyerName.isEmpty || buyerContact.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter buyer name and contact.')),
      );
      return;
    }

    if (_selectedSaleType == SaleType.credit && _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer.')),
      );
      return;
    }

    if (_deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device not ready yet. Please try again.')),
      );
      return;
    }

    final newSale = Sale.create(
      customerUuid: _selectedCustomer?.uuid,
      buyerName: buyerName,
      buyerContact: buyerContact,
      totalAmount: _calculateTotalAmount(),
      amountReceived:
          double.tryParse(_amountReceivedController.text) ?? 0.0,
      date: _selectedDate,
      items: _saleItems,
      saleType: _selectedSaleType,
      comment: () {
        String c = _commentController.text.trim();
        if (_extraCharges.isNotEmpty) {
          final lines = _extraCharges
              .where((e) => e['key']!.text.isNotEmpty && e['value']!.text.isNotEmpty)
              .map((e) => '${e['key']!.text}: Rs.${e['value']!.text}')
              .join(', ');
          if (lines.isNotEmpty) c = c.isEmpty ? 'Charges: $lines' : '$c | Charges: $lines';
        }
        return c.isEmpty ? null : c;
      }(),
      deviceId: _deviceId,
    );

    if (widget.existingSale != null) {
      newSale.isarId = widget.existingSale!.isarId;
      newSale.uuid = widget.existingSale!.uuid;
    }

    // Stock warning check (fixed: by productUuid)
    List<String> warningItems = [];
    for (final item in _saleItems) {
      final matchingProduct =
          _products.where((p) => p.uuid == item.productUuid).firstOrNull;

      if (matchingProduct != null) {
        final projectedQty = matchingProduct.quantity - item.quantity;
        if (projectedQty < 0) {
          warningItems.add(
              '${item.productName} (will be $projectedQty)');
        }
      }
    }

    if (warningItems.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stock Warning'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The following items will go below 0 stock:'),
              const SizedBox(height: 8),
              ...warningItems.map((item) => Text(item)),
              const SizedBox(height: 12),
              const Text('Do you want to continue anyway?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);
    try {
      await _db.recordSale(newSale);
      await PDFService.generateInvoice(newSale);
      
      for (final entry in _productsToUpdatePrice.entries) {
        final productUuid = entry.key;
        final newPrice = entry.value;
        final productToUpdate = await _db.getProductByUuid(productUuid);
        if (productToUpdate != null) {
          productToUpdate.salePrice = newPrice;
          await _db.updateProduct(productToUpdate);
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale completed & PDF generated.')),
      );

      setState(() {
        _saleItems.clear();
        _buyerNameController.clear();
        _buyerContactController.clear();
        _selectedCustomer = null;
        _searchProductController.clear();
        _filteredProducts = _products;
        _commentController.clear();
        _amountReceivedController.clear();
        _selectedDate = DateTime.now();
        _productsToUpdatePrice.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete sale: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPhone = false, Key? key}) {
    return TextField(
      key: key,
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Sale')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RadioListTile<SaleType>(
                title: const Text('Cash Sale'),
                value: SaleType.cash,
                groupValue: _selectedSaleType,
                onChanged: (val) {
                  setState(() {
                    _selectedSaleType = val!;
                    _selectedCustomer = null;
                    _buyerNameController.clear();
                    _buyerContactController.clear();
                  });
                },
              ),
              RadioListTile<SaleType>(
                title: const Text('Customer Sale'),
                value: SaleType.credit,
                groupValue: _selectedSaleType,
                onChanged: (val) {
                  setState(() {
                    _selectedSaleType = val!;
                    _buyerNameController.clear();
                    _buyerContactController.clear();
                  });
                },
              ),
              const SizedBox(height: 10),
              if (_selectedSaleType == SaleType.cash) ...[
                _buildTextField(_buyerNameController, 'Buyer Name', key: const Key('buyerNameField')),
                const SizedBox(height: 10),
                _buildTextField(_buyerContactController, 'Buyer Contact', isPhone: true, key: const Key('buyerContactField')),
              ] else ...[
                DropdownButtonFormField<Customer>(
                  value: _selectedCustomer,
                  items: _customers.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${c.name} (${c.phone})'),
                    );
                  }).toList(),
                  onChanged: (c) {
                    setState(() {
                      _selectedCustomer = c;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Customer',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('searchProductField'),
                      controller: _searchProductController,
                      decoration: InputDecoration(
                        labelText: 'Search Products',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    key: const Key('customItemButton'),
                    onPressed: _showCustomItemDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Custom Item'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: _filteredProducts.isEmpty
                    ? const Center(child: Text('No products found'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ActionChip(
                              key: Key('productChip_${product.name}'),
                              backgroundColor: Colors.indigo.shade100,
                              label: Text(product.name),
                              onPressed: () => _showQuantityDialog(product),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              _saleItems.isEmpty
                  ? const Center(child: Text('No items added.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _saleItems.length,
                      itemBuilder: (context, index) {
                        final item = _saleItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            key: Key('addedItem_${item.productName}'),
                            title: Text(item.productName),
                            subtitle: Text(
                              'Qty: ${item.quantity} x ₹${item.unitPrice.toStringAsFixed(2)} = ₹${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                            ),
                            onTap: () => _editItem(item),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(item),
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountReceivedController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount Received',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
// ── Extra Charges ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Extra Charges',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _extraCharges.add({
                                'key': TextEditingController(),
                                'value': TextEditingController(),
                              });
                            });
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    ..._extraCharges.asMap().entries.map((entry) {
                      final i = entry.key;
                      final charge = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: charge['key'],
                                decoration: const InputDecoration(
                                  labelText: 'Label (e.g. Courier)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: charge['value'],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}), // recompute total live
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  charge['key']!.dispose();
                                  charge['value']!.dispose();
                                  _extraCharges.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Items Total:', style: TextStyle(fontSize: 15)),
                        const Spacer(),
                        Text(
                          'Rs.${_saleItems.fold(0.0, (sum, item) => sum + item.unitPrice * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    if (_extraCharges.isNotEmpty) ...[
                      const Divider(height: 12),
                      ..._extraCharges.map((charge) {
                        final label = charge['key']!.text.isEmpty ? 'Extra' : charge['key']!.text;
                        final amount = double.tryParse(charge['value']!.text) ?? 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const Spacer(),
                              Text('Rs.${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        );
                      }),
                    ],
                    const Divider(height: 12),
                    Row(
                      children: [
                        const Text('Grand Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          'Rs.${_calculateTotalAmount().toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                key: const Key('saveSaleButton'),
                onPressed: _isSaving ? null : _completeSale,
                icon: const Icon(Icons.check_circle),
                label: Text(_isSaving ? 'Completing...' : 'Complete Sale'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
