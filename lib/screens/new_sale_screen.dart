import 'package:flutter/material.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/sale_item.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';
import 'package:ssma/services/pdf_service.dart';
import 'package:ssma/utils/sale_metadata.dart';
import 'package:ssma/utils/search_utils.dart';



enum PriceChangeMode { temporary, permanent }

class _PendingPriceUpdate {
  final double purchasePrice;
  final double salePrice;
  final String? name;

  const _PendingPriceUpdate({
    required this.purchasePrice,
    required this.salePrice,
    this.name,
  });
}

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
  Future<void> updateProduct(Product product) =>
      DBService.updateProduct(product);

  @override
  Future<Product?> getProductByUuid(String uuid) =>
      DBService.getProductByUuid(uuid);
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
  final TextEditingController _searchProductController =
      TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountReceivedController =
      TextEditingController();
  final List<Map<String, TextEditingController>> _extraCharges = [];

  SaleType _selectedSaleType = SaleType.cash;
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  String _deviceId = '';
  bool _isSaving = false;
  final Map<String, _PendingPriceUpdate> _productsToUpdatePrice = {};
  final List<Map<String, TextEditingController>> _paymentRows = [];

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
      final metadata = SaleMetadata.parse(sale.comment);
      _saleItems = List.from(sale.items);
      _buyerNameController.text = sale.buyerName ?? '';
      _buyerContactController.text = sale.buyerContact ?? '';
      _commentController.text = metadata.visibleComment ?? '';
      _amountReceivedController.text = sale.amountReceived.toString();
      _selectedDate = sale.date;
      _selectedSaleType = sale.saleType;
      for (final payment in metadata.payments) {
        _paymentRows.add({
          'method': TextEditingController(text: payment.method),
          'amount': TextEditingController(text: payment.amount.toString()),
        });
      }
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
    for (final payment in _paymentRows) {
      payment['method']!.dispose();
      payment['amount']!.dispose();
    }
    super.dispose(); // must be last
  }

  Future<void> loadData() async {
    _deviceId = await DeviceService.getDeviceId();
    // -> now uses injected service (or real adapter)
    final products = await _db.getProducts();
    final customers = await _db.getCustomers();
    if (!mounted) return;
    setState(() {
      _products = products;
      _filteredProducts = products;
      _customers = customers;
    });

    // Preselect customer if editing and it's a credit sale
    if (widget.existingSale != null &&
        widget.existingSale!.saleType == SaleType.credit) {
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
    setState(() {
      _filteredProducts = SearchUtils.fuzzySort<Product>(
        _products,
        query,
        (product) => product.name,
      );
    });
  }

  void _showQuantityDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final qtyController = TextEditingController(text: '1');
    final purchasePriceController =
        TextEditingController(text: product.purchasePrice.toStringAsFixed(2));
    final priceController =
        TextEditingController(text: product.salePrice.toStringAsFixed(2));
    PriceChangeMode priceMode = PriceChangeMode.temporary;

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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name (on bill)',
                    helperText: 'Edit to show a different name on this bill',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: purchasePriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Purchase Price'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Selling Price'),
                ),
                const SizedBox(height: 8),
                SegmentedButton<PriceChangeMode>(
                  segments: const [
                    ButtonSegment(
                      value: PriceChangeMode.temporary,
                      label: Text('This bill only'),
                      icon: Icon(Icons.receipt_long),
                    ),
                    ButtonSegment(
                      value: PriceChangeMode.permanent,
                      label: Text('Save to inventory'),
                      icon: Icon(Icons.inventory),
                    ),
                  ],
                  selected: {priceMode},
                  onSelectionChanged: (selection) {
                    setDialogState(() {
                      priceMode = selection.first;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(qtyController.text);
                final purchasePrice =
                    double.tryParse(purchasePriceController.text);
                final price = double.tryParse(priceController.text);
                final billName = nameController.text.trim();

                if (qty != null &&
                    qty > 0 &&
                    purchasePrice != null &&
                    purchasePrice >= 0 &&
                    price != null &&
                    price >= 0 &&
                    billName.isNotEmpty) {
                  if (priceMode == PriceChangeMode.permanent) {
                    final confirmed = await showDialog<bool>(
                      context: innerContext,
                      builder: (confirmContext) => AlertDialog(
                        title: const Text('Save to inventory?'),
                        content: Text(
                          'Future bills will use name "${billName}", '
                          'purchase ₹${purchasePrice.toStringAsFixed(2)} and '
                          'selling ₹${price.toStringAsFixed(2)} for ${product.name}.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(confirmContext, false),
                            child: const Text('Keep Temporary'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(confirmContext, true),
                            child: const Text('Save Permanently'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    _productsToUpdatePrice[product.uuid] = _PendingPriceUpdate(
                      purchasePrice: purchasePrice,
                      salePrice: price,
                      name: billName != product.name ? billName : null,
                    );
                  }

                  if (!mounted) return;
                  setState(() {
                    _saleItems.add(
                      SaleItem.create(
                        productUuid: product.uuid,
                        productName: billName,
                        quantity: qty,
                        unitPrice: price,
                        purchasePrice: purchasePrice,
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
              decoration: const InputDecoration(labelText: 'Purchase Price'),
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
    final nameController = TextEditingController(text: item.productName);
    final qtyController =
        TextEditingController(text: item.quantity.toStringAsFixed(0));
    final purchaseController =
        TextEditingController(text: item.purchasePrice.toStringAsFixed(2));
    final priceController =
        TextEditingController(text: item.unitPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${item.productName}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name (on bill)',
                  helperText: 'Edit to change name on this bill only',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: purchaseController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Purchase Price'),
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
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text);
              final purchase = double.tryParse(purchaseController.text);
              final price = double.tryParse(priceController.text);
              final billName = nameController.text.trim();
              if (qty != null &&
                  qty > 0 &&
                  purchase != null &&
                  purchase >= 0 &&
                  price != null &&
                  price >= 0 &&
                  billName.isNotEmpty) {
                setState(() {
                  item.productName = billName;
                  item.quantity = qty.toInt();
                  item.purchasePrice = purchase;
                  item.unitPrice = price;
                  item.total = item.quantity * item.unitPrice;
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
    final itemsTotal = _saleItems.fold(
        0.0, (sum, item) => sum + item.unitPrice * item.quantity);
    return itemsTotal + _calculateExtraCharges();
  }

  List<SalePaymentEntry> _collectPayments() {
    return _paymentRows
        .map((row) {
          final method = row['method']!.text.trim();
          final amount = double.tryParse(row['amount']!.text.trim()) ?? 0;
          return SalePaymentEntry(
            method: method.isEmpty ? 'Payment' : method,
            amount: amount,
          );
        })
        .where((entry) => entry.amount > 0)
        .toList();
  }

  double _paymentTotal() {
    if (_paymentRows.isEmpty) {
      return double.tryParse(_amountReceivedController.text.trim()) ?? 0.0;
    }
    return _collectPayments().fold(0.0, (sum, entry) => sum + entry.amount);
  }

  void _addPaymentRow({String method = 'Cash', String amount = ''}) {
    setState(() {
      _paymentRows.add({
        'method': TextEditingController(text: method),
        'amount': TextEditingController(text: amount),
      });
    });
  }

  Future<void> _completeSale() async {
    if (_isSaving) return;

    if (_saleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least one item to complete sale.')),
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
        const SnackBar(
            content: Text('Device not ready yet. Please try again.')),
      );
      return;
    }

    final totalAmount = _calculateTotalAmount();
    final paymentEntries = _collectPayments();
    final amountReceived = _paymentRows.isEmpty
        ? (double.tryParse(_amountReceivedController.text.trim()) ?? 0.0)
        : paymentEntries.fold(0.0, (sum, entry) => sum + entry.amount);

    if (amountReceived - totalAmount > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payments cannot exceed bill total.')),
      );
      return;
    }

    final newSale = Sale.create(
      customerUuid: _selectedCustomer?.uuid,
      buyerName: buyerName,
      buyerContact: buyerContact,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
      date: _selectedDate,
      items: _saleItems,
      saleType: _selectedSaleType,
      comment: () {
        String c = _commentController.text.trim();
        if (_extraCharges.isNotEmpty) {
          final lines = _extraCharges
              .where((e) =>
                  e['key']!.text.isNotEmpty && e['value']!.text.isNotEmpty)
              .map((e) => '${e['key']!.text}: Rs.${e['value']!.text}')
              .join(', ');
          if (lines.isNotEmpty) {
            c = c.isEmpty ? 'Charges: $lines' : '$c | Charges: $lines';
          }
        }
        return SaleMetadata.compose(
          visibleComment: c.isEmpty ? null : c,
          payments: paymentEntries,
          billingMode: 'creditDebit',
        );
      }(),
      deviceId: _deviceId,
    );

    if (widget.existingSale != null) {
      newSale.isarId = widget.existingSale!.isarId;
      newSale.uuid = widget.existingSale!.uuid;
      newSale.createdAt = widget.existingSale!.createdAt;
      newSale.version = widget.existingSale!.version + 1;
    }

    // Stock warning check (fixed: by productUuid)
    List<String> warningItems = [];
    for (final item in _saleItems) {
      final matchingProduct =
          _products.where((p) => p.uuid == item.productUuid).firstOrNull;

      if (matchingProduct != null) {
        final projectedQty = matchingProduct.quantity - item.quantity;
        if (projectedQty < 0) {
          warningItems.add('${item.productName} (will be $projectedQty)');
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
        final newPrices = entry.value;
        final productToUpdate = await _db.getProductByUuid(productUuid);
        if (productToUpdate != null) {
          productToUpdate.purchasePrice = newPrices.purchasePrice;
          productToUpdate.salePrice = newPrices.salePrice;
          if (newPrices.name != null && newPrices.name!.isNotEmpty) {
            productToUpdate.name = newPrices.name!;
          }
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
        for (final payment in _paymentRows) {
          payment['method']!.dispose();
          payment['amount']!.dispose();
        }
        _paymentRows.clear();
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

  Widget _buildCustomerSearch() {
    return RawAutocomplete<Customer>(
      displayStringForOption: (customer) =>
          '${customer.name}${customer.phone == null ? '' : ' (${customer.phone})'}',
      optionsBuilder: (textEditingValue) {
        return SearchUtils.fuzzySort<Customer>(
          _customers,
          textEditingValue.text,
          (customer) => '${customer.name} ${customer.phone ?? ''}',
        ).take(30);
      },
      onSelected: (customer) {
        setState(() {
          _selectedCustomer = customer;
          _buyerNameController.text = customer.name;
          _buyerContactController.text = customer.phone ?? '';
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (_selectedCustomer != null && controller.text.isEmpty) {
          controller.text =
              '${_selectedCustomer!.name} (${_selectedCustomer!.phone ?? 'No phone'})';
        }
        return TextField(
          key: const Key('customerSearchField'),
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Search Party / Customer',
            hintText: 'Type party name or phone',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _selectedCustomer == null
                ? null
                : IconButton(
                    tooltip: 'Clear selected party',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        _selectedCustomer = null;
                        _buyerNameController.clear();
                        _buyerContactController.clear();
                      });
                    },
                  ),
            border: const OutlineInputBorder(),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, maxWidth: 420),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final customer = options.elementAt(index);
                  return ListTile(
                    title: Text(customer.name),
                    subtitle: Text(customer.phone ?? 'No phone'),
                    onTap: () => onSelected(customer),
                  );
                },
              ),
            ),
          ),
        );
      },
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
              const SizedBox(height: 10),
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
                _buildTextField(_buyerNameController, 'Buyer Name',
                    key: const Key('buyerNameField')),
                const SizedBox(height: 10),
                _buildTextField(_buyerContactController, 'Buyer Contact',
                    isPhone: true, key: const Key('buyerContactField')),
              ] else ...[
                _buildCustomerSearch(),
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    key: const Key('customItemButton'),
                    onPressed: _showCustomItemDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Custom Item'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
                              'Qty: ${item.quantity} x ₹${item.unitPrice.toStringAsFixed(2)} = ₹${(item.unitPrice * item.quantity).toStringAsFixed(2)}\nPurchase: ₹${item.purchasePrice.toStringAsFixed(2)}',
                            ),
                            isThreeLine: true,
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount Received',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Payment Breakdown',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _addPaymentRow(method: 'Cash'),
                          icon: const Icon(Icons.payments, size: 18),
                          label: const Text('Cash'),
                        ),
                        TextButton.icon(
                          onPressed: () => _addPaymentRow(method: 'UPI'),
                          icon: const Icon(Icons.qr_code, size: 18),
                          label: const Text('UPI'),
                        ),
                        IconButton(
                          tooltip: 'Add payment method',
                          onPressed: () => _addPaymentRow(method: 'Bank'),
                          icon: const Icon(Icons.add_card),
                        ),
                      ],
                    ),
                    if (_paymentRows.isEmpty)
                      Text(
                        'Use Amount Received for a single payment, or add rows for split payments.',
                        style: TextStyle(color: Colors.grey.shade700),
                      )
                    else
                      ..._paymentRows.asMap().entries.map((entry) {
                        final i = entry.key;
                        final payment = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: payment['method'],
                                  decoration: const InputDecoration(
                                    labelText: 'Method',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: payment['amount'],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove payment',
                                icon: const Icon(Icons.close,
                                    color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    payment['method']!.dispose();
                                    payment['amount']!.dispose();
                                    _paymentRows.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Text('Received total:'),
                        const Spacer(),
                        Text('Rs.${_paymentTotal().toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Remaining:'),
                        const Spacer(),
                        Text(
                          'Rs.${(_calculateTotalAmount() - _paymentTotal()).clamp(0.0, double.infinity).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _calculateTotalAmount() - _paymentTotal() > 0
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (_) =>
                                    setState(() {}), // recompute total live
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.red, size: 20),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Items Total:',
                            style: TextStyle(fontSize: 15)),
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
                        final label = charge['key']!.text.isEmpty
                            ? 'Extra'
                            : charge['key']!.text;
                        final amount =
                            double.tryParse(charge['value']!.text) ?? 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(label,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              const Spacer(),
                              Text('Rs.${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        );
                      }),
                    ],
                    const Divider(height: 12),
                    Row(
                      children: [
                        const Text('Grand Total:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          'Rs.${_calculateTotalAmount().toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
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
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
