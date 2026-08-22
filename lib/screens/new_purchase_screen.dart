import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/purchase_item.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';
import 'package:ssma/utils/search_utils.dart';

class NewPurchaseScreen extends StatefulWidget {
  final Supplier supplier;

  const NewPurchaseScreen({super.key, required this.supplier});

  @override
  State<NewPurchaseScreen> createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends State<NewPurchaseScreen> {
  List<Product> _products = [];
  List<Product> _recommendations = [];
  final List<PurchaseItem> _items = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;
  bool _loading = true;
  late String _deviceId;

  final NumberFormat _currencyFmt =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _deviceId = await DeviceService.getDeviceId();
    await _loadProducts();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;
        if (_isSearching) {
          _updateRecommendations();
        }
      });
    });
  }

  Future<void> _loadProducts() async {
    final list = await DBService.getProducts();
    if (mounted) {
      setState(() {
        _products = list.where((p) => !p.deleted).toList();
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    _updateRecommendations();
  }

  void _updateRecommendations() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _recommendations = _products.take(6).toList();
      });
    } else {
      final matches = SearchUtils.fuzzySort<Product>(
        _products,
        query,
        (p) => '${p.name} ${p.salePrice} ${p.purchasePrice}',
      );
      setState(() {
        _recommendations = matches.take(8).toList();
      });
    }
  }

  void _selectProduct(Product product) {
    final existing =
        _items.where((i) => i.productUuid == product.uuid).firstOrNull;
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
    });
    _addOrEditItem(product: product, existing: existing);
  }

  void _addNewCustomProduct(String name) async {
    final nameController = TextEditingController(text: name);
    final salePriceController = TextEditingController();
    final purchasePriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: purchasePriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Purchase / Cost Price (₹)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: salePriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Selling / Retail Price (₹)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prodName = nameController.text.trim();
              final cost = double.tryParse(purchasePriceController.text) ?? 0.0;
              final retail = double.tryParse(salePriceController.text) ?? cost;

              if (prodName.isEmpty) return;

              final newProd = Product.create(
                name: prodName,
                purchasePrice: cost,
                salePrice: retail,
                quantity: 0,
                deviceId: _deviceId,
              );

              await DBService.addProduct(newProd);
              await _loadProducts();

              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (mounted) {
                _selectProduct(newProd);
              }
            },
            child: const Text('Create & Add'),
          ),
        ],
      ),
    );
  }

  void _addOrEditItem({required Product product, PurchaseItem? existing}) {
    final qtyController =
        TextEditingController(text: existing != null ? '${existing.quantity}' : '1');
    final priceController = TextEditingController(
      text: existing != null
          ? existing.purchasePrice.toStringAsFixed(2)
          : product.purchasePrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              existing != null ? Icons.edit_note_rounded : Icons.add_shopping_cart_rounded,
              color: Colors.indigo,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${existing != null ? "Edit" : "Add"} ${product.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current stock in shop: ${product.quantity} units',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity (Units)',
                prefixIcon: Icon(Icons.numbers_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Purchase Price per Unit (₹)',
                prefixIcon: Icon(Icons.currency_rupee_rounded),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              final quantity = int.tryParse(qtyController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0.0;

              if (quantity <= 0 || price < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid quantity and price.')),
                );
                return;
              }

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
                    deviceId: _deviceId,
                  ));
                }
              });

              Navigator.pop(ctx);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  double get total => _items.fold(0.0, (sum, item) => sum + item.total);

  Future<void> _savePurchase() async {
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to this purchase.')),
      );
      return;
    }

    final purchase = Purchase.create(
      supplierUuid: widget.supplier.uuid,
      purchaseItems: _items,
      totalAmount: total,
      date: DateTime.now(),
      deviceId: _deviceId,
      amountPaid: amountPaid,
      note: _noteController.text.trim(),
    );

    await DBService.addPurchase(purchase);

    // Refresh purchase price metadata on products
    for (final item in _items) {
      final product = await DBService.getProductByUuid(item.productUuid);
      if (product != null) {
        product.purchasePrice = item.purchasePrice;
        product.updatedAt = DateTime.now();
        product.version += 1;
        product.isSynced = false;
        await DBService.updateProduct(product);
      }
    }

    // Record supplier payment if partial or full payment was made
    if (amountPaid > 0) {
      final payment = SupplierPayment.create(
        supplierUuid: widget.supplier.uuid,
        amount: amountPaid,
        date: DateTime.now(),
        note: "Payment during purchase #${purchase.isarId}",
        deviceId: _deviceId,
      );

      await DBService.addSupplierPayment(payment);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Purchase recorded successfully.')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _noteController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Stock Purchase',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('Supplier: ${widget.supplier.name}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                if (_searchFocusNode.hasFocus) {
                  _searchFocusNode.unfocus();
                  setState(() => _isSearching = false);
                }
              },
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Search Bar (Primary Source of Adding Products)
                    _buildSearchBar(isDark),

                    // Dropdown Box for Recommendations & Search Results
                    if (_isSearching) _buildRecommendationsDropdown(isDark),

                    // Selected Items & Billing Section
                    Expanded(
                      child: ListView(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selected Purchase Items (${_items.length}):',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (_items.isNotEmpty)
                                TextButton.icon(
                                  icon: const Icon(Icons.clear_all, size: 16),
                                  label: const Text('Clear All',
                                      style: TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    setState(() => _items.clear());
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          if (_items.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.03)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: isDark ? Colors.white10 : Colors.grey.shade300),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_rounded,
                                      size: 40,
                                      color: isDark ? Colors.grey[600] : Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Type in the search bar above to select products',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return _buildItemCard(item, index, isDark);
                            }),

                          const SizedBox(height: 16),
                          const Divider(),

                          // Purchase Financial Summary Card
                          _buildFinancialSummary(isDark),

                          const SizedBox(height: 12),

                          // Amount Paid Now
                          TextField(
                            controller: _amountPaidController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Amount Paid to Supplier Now (₹)',
                              prefixIcon: const Icon(Icons.payments_outlined),
                              hintText: '0.00',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.04)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Optional Note
                          TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              labelText: 'Purchase Note / Bill No. (optional)',
                              prefixIcon: const Icon(Icons.note_alt_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.04)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Save Purchase Button
                    ElevatedButton.icon(
                      onPressed: _items.isEmpty ? null : _savePurchase,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(
                        'Confirm & Save Purchase (${_currencyFmt.format(total)})',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search product by name or barcode to add...',
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.indigo),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _updateRecommendations();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _searchFocusNode.hasFocus ? Colors.indigo : Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        ),
      ),
    );
  }

  // ─── Recommendations Dropdown Box ──────────────────────────────────────────
  Widget _buildRecommendationsDropdown(bool isDark) {
    final query = _searchController.text.trim();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          if (_recommendations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No products matching "$query"',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ..._recommendations.map((p) {
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.indigo.withOpacity(0.12),
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.indigo),
                  ),
                ),
                title: Text(p.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(
                  'Cost: ${_currencyFmt.format(p.purchasePrice)} • Stock: ${p.quantity}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                trailing: const Icon(Icons.add_circle_outline,
                    color: Colors.indigo, size: 20),
                onTap: () => _selectProduct(p),
              );
            }),
          if (query.isNotEmpty) ...[
            const Divider(height: 1),
            ListTile(
              dense: true,
              leading: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.green,
                child: Icon(Icons.add, color: Colors.white, size: 14),
              ),
              title: Text('Add "$query" as new product',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.green)),
              onTap: () {
                _addNewCustomProduct(query);
              },
            ),
          ],
        ],
      ),
    );
  }

  // ─── Selected Item Card ───────────────────────────────────────────────────
  Widget _buildItemCard(PurchaseItem item, int index, bool isDark) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.12),
          child: Text('${index + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.indigo)),
        ),
        title: Text(item.productName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          '${item.quantity} units × ${_currencyFmt.format(item.purchasePrice)} = ${_currencyFmt.format(item.total)}',
          style: TextStyle(
              fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20, color: Colors.blue),
              tooltip: 'Edit quantity/price',
              onPressed: () {
                final product = _products
                    .firstWhere((p) => p.uuid == item.productUuid,
                        orElse: () => Product.create(
                              name: item.productName,
                              purchasePrice: item.purchasePrice,
                              salePrice: item.purchasePrice,
                              quantity: item.quantity,
                              deviceId: _deviceId,
                            ));
                _addOrEditItem(product: product, existing: item);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 20, color: Colors.red),
              tooltip: 'Remove item',
              onPressed: () {
                setState(() => _items.remove(item));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Financial Summary Box ─────────────────────────────────────────────────
  Widget _buildFinancialSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.indigo.withOpacity(0.3) : Colors.indigo.shade100,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Purchase Value',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Payable for selected items',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Text(
            _currencyFmt.format(total),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}
