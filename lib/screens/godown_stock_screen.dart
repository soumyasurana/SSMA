import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssma/models/godown_item.dart';
import 'package:ssma/models/godown_movement.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';
import 'package:ssma/utils/search_utils.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;

class GodownStockScreen extends StatefulWidget {
  const GodownStockScreen({super.key});

  @override
  State<GodownStockScreen> createState() => _GodownStockScreenState();
}

class _GodownStockScreenState extends State<GodownStockScreen> {
  final _searchController = TextEditingController();
  List<GodownItem> _items = [];
  List<GodownItem> _filteredItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_filterItems);
    syncV2?.statusNotifier.addListener(_onSyncChanged);
  }

  void _onSyncChanged() {
    if (mounted) {
      _loadItems();
    }
  }

  @override
  void dispose() {
    syncV2?.statusNotifier.removeListener(_onSyncChanged);
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await DBService.getGodownItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _filteredItems = SearchUtils.fuzzySort<GodownItem>(
        _items,
        _searchController.text,
        (item) => item.name,
      );
      _loading = false;
    });
  }

  void _filterItems() {
    setState(() {
      _filteredItems = SearchUtils.fuzzySort<GodownItem>(
        _items,
        _searchController.text,
        (item) => item.name,
      );
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ADD STOCK DIALOG — pick product from inventory
  // ───────────────────────────────────────────────────────────────────────────
  void _showAddStockDialog() async {
    // Load all inventory products
    final allProducts = await DBService.getProducts();
    if (!mounted) return;

    Product? selectedProduct;
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    final productSearchController = TextEditingController();
    List<Product> filteredProducts = List.from(allProducts);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          void filterProducts(String query) {
            setDialogState(() {
              filteredProducts = SearchUtils.fuzzySort<Product>(
                allProducts,
                query,
                (p) => p.name,
              );
            });
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Add Stock to Godown'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Product Picker ──────────────────────────────────
                  const Text('Select Product from Inventory *',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: productSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search inventory...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      suffixIcon: selectedProduct != null
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setDialogState(() {
                                  selectedProduct = null;
                                  productSearchController.clear();
                                  filteredProducts = List.from(allProducts);
                                });
                              })
                          : null,
                    ),
                    onChanged: filterProducts,
                  ),
                  const SizedBox(height: 4),
                  // Product list / selected product — fixed height box
                  SizedBox(
                    height: 160,
                    child: selectedProduct != null
                        ? Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.indigo.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.indigo, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedProduct!.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        'Shop stock: ${selectedProduct!.quantity}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : filteredProducts.isNotEmpty
                            ? ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (_, i) {
                                  final p = filteredProducts[i];
                                  return ListTile(
                                    dense: true,
                                    title: Text(p.name),
                                    subtitle: Text('Stock: ${p.quantity}',
                                        style:
                                            const TextStyle(fontSize: 11)),
                                    onTap: () {
                                      setDialogState(() {
                                        selectedProduct = p;
                                        productSearchController.text = p.name;
                                        if (costController.text.isEmpty &&
                                            p.purchasePrice > 0) {
                                          costController.text =
                                              p.purchasePrice
                                                  .toStringAsFixed(2);
                                        }
                                      });
                                    },
                                  );
                                },
                              )
                            : const Center(
                                child: Text('No products found in inventory',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                  ),
                  const SizedBox(height: 14),
                  // ─── Quantity ───────────────────────────────────────
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity to add to Godown *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Unit Cost (₹)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedProduct == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please select a product from inventory')),
                    );
                    return;
                  }
                  final qty = int.tryParse(qtyController.text.trim());
                  if (qty == null || qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a valid quantity')),
                    );
                    return;
                  }

                  final unitCost =
                      double.tryParse(costController.text.trim()) ?? 0.0;
                  final deviceId = await DeviceService.getDeviceId();

                  Navigator.pop(dialogCtx);

                  // Check if this product already has a godown entry
                  final existing = _items.where((gi) =>
                      gi.productUuid == selectedProduct!.uuid).toList();

                  if (existing.isNotEmpty) {
                    // Increase existing godown entry
                    await DBService.adjustGodownQuantity(
                      godownItemUuid: existing.first.uuid,
                      deltaQuantity: qty,
                      note: 'Stock added from inventory',
                    );
                  } else {
                    final newItem = GodownItem.create(
                      name: selectedProduct!.name,
                      quantity: qty,
                      unitCost: unitCost,
                      productUuid: selectedProduct!.uuid,
                      deviceId: deviceId,
                    );
                    await DBService.addGodownItem(newItem);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Added $qty units of "${selectedProduct!.name}" to Godown')),
                    );
                  }
                  _loadItems();
                },
                child: const Text('Add to Godown'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // EDIT ITEM DIALOG (name is locked to inventory product name)
  // ───────────────────────────────────────────────────────────────────────────
  void _showEditDialog(GodownItem existingItem) {
    final costController = TextEditingController(
        text: existingItem.unitCost > 0
            ? existingItem.unitCost.toStringAsFixed(2)
            : '');
    final notesController =
        TextEditingController(text: existingItem.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Godown Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name is read-only (locked to inventory product)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                child: Text(existingItem.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Unit Cost (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final unitCost =
                  double.tryParse(costController.text.trim()) ?? 0.0;
              final notes = notesController.text.trim();

              Navigator.pop(dialogCtx);

              existingItem.unitCost = unitCost;
              existingItem.notes = notes.isNotEmpty ? notes : null;
              await DBService.updateGodownItem(existingItem);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Godown item updated')),
                );
              }
              _loadItems();
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ADJUST QUANTITY DIALOG (+ / -)
  // ───────────────────────────────────────────────────────────────────────────
  void _showAdjustQuantityDialog(GodownItem item, bool isIncrease) {
    final controller = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isIncrease ? 'Increase Quantity' : 'Decrease Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item: ${item.name}\nCurrent Stock: ${item.quantity} ${item.unit ?? ""}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: isIncrease ? 'Quantity to add' : 'Quantity to remove',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Reason / Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isIncrease ? Colors.green : Colors.orange,
            ),
            onPressed: () async {
              final val = int.tryParse(controller.text.trim());
              if (val == null || val <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid positive number')),
                );
                return;
              }
              final delta = isIncrease ? val : -val;

              if (!isIncrease && val > item.quantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Cannot remove $val units. Available: ${item.quantity}'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogCtx);
              try {
                await DBService.adjustGodownQuantity(
                  godownItemUuid: item.uuid,
                  deltaQuantity: delta,
                  note: noteController.text.trim().isNotEmpty
                      ? noteController.text.trim()
                      : null,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isIncrease
                            ? 'Added $val units to ${item.name}'
                            : 'Removed $val units from ${item.name}',
                      ),
                    ),
                  );
                }
                _loadItems();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(isIncrease ? 'Increase' : 'Decrease'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TRANSFER TO SHOP DIALOG
  // ───────────────────────────────────────────────────────────────────────────
  void _showTransferToShopDialog(GodownItem item) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.storefront, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Transfer to Shop'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Godown Stock: ${item.quantity} ${item.unit ?? "units"}',
                    style: TextStyle(color: Colors.indigo.shade900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Quantity to transfer *',
                hintText: 'e.g. 200',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Transferred stock will be deducted from godown and added to shop inventory.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              final qty = int.tryParse(controller.text.trim());
              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a valid positive transfer quantity')),
                );
                return;
              }

              if (qty > item.quantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red.shade700,
                    content: Text(
                        '❌ Transfer rejected: Requested $qty units, but only ${item.quantity} available in Godown.'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogCtx);

              try {
                await DBService.transferGodownToShop(
                  godownItemUuid: item.uuid,
                  transferQuantity: qty,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '✅ Successfully transferred $qty units of "${item.name}" to Shop Inventory.'),
                    ),
                  );
                }
                _loadItems();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Transfer failed: $e'),
                    ),
                  );
                }
              }
            },
            child: const Text('Transfer Now'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // VIEW STOCK MOVEMENT HISTORY
  // ───────────────────────────────────────────────────────────────────────────
  void _showMovementHistory(GodownItem item) async {
    final movements = await DBService.getGodownMovements(item.uuid);
    if (!mounted) return;

    final dateFormatter = DateFormat('dd MMM yyyy – hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'History: ${item.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Current Stock: ${item.quantity} ${item.unit ?? ""}',
                style: const TextStyle(color: Colors.grey),
              ),
              const Divider(),
              Expanded(
                child: movements.isEmpty
                    ? const Center(child: Text('No movement history recorded.'))
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: movements.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final m = movements[index];
                          IconData icon;
                          Color color;
                          String label;

                          switch (m.movementType) {
                            case GodownMovementType.stockAdded:
                              icon = Icons.add_circle;
                              color = Colors.green;
                              label = 'Stock Added';
                              break;
                            case GodownMovementType.quantityIncreased:
                              icon = Icons.arrow_upward;
                              color = Colors.green;
                              label = 'Quantity Increased';
                              break;
                            case GodownMovementType.quantityDecreased:
                              icon = Icons.arrow_downward;
                              color = Colors.orange;
                              label = 'Quantity Decreased';
                              break;
                            case GodownMovementType.transferToShop:
                              icon = Icons.storefront;
                              color = Colors.indigo;
                              label = 'Transferred to Shop';
                              break;
                            case GodownMovementType.manualAdjustment:
                              icon = Icons.edit;
                              color = Colors.blue;
                              label = 'Details Updated';
                              break;
                            case GodownMovementType.stockRemoved:
                              icon = Icons.delete;
                              color = Colors.red;
                              label = 'Stock Removed';
                              break;
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.1),
                              child: Icon(icon, color: color),
                            ),
                            title: Text(label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (m.note != null && m.note!.isNotEmpty)
                                  Text(m.note!),
                                Text(
                                  dateFormatter.format(m.createdAt),
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  m.quantityChanged >= 0
                                      ? '+${m.quantityChanged}'
                                      : '${m.quantityChanged}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: m.quantityChanged >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  'Bal: ${m.remainingQuantity}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DELETE ITEM CONFIRMATION
  // ───────────────────────────────────────────────────────────────────────────
  void _confirmDelete(GodownItem item) {
    final willRestoreToInventory =
        item.productUuid != null && item.productUuid!.isNotEmpty;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Remove Godown Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Remove "${item.name}" from godown?'),
            if (willRestoreToInventory && item.quantity > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.undo, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.quantity} units will be restored back to shop inventory.',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await DBService.deleteGodownItem(item.uuid);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      willRestoreToInventory && item.quantity > 0
                          ? 'Removed "${item.name}" from godown. ${item.quantity} units returned to inventory.'
                          : 'Removed "${item.name}" from godown',
                    ),
                  ),
                );
              }
              _loadItems();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Godown Stock'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'All Stock Movements',
            onPressed: () async {
              final allMovements = await DBService.getAllGodownMovements();
              if (!mounted) return;
              final dateFormatter = DateFormat('dd MMM yyyy – hh:mm a');

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  maxChildSize: 0.95,
                  minChildSize: 0.4,
                  expand: false,
                  builder: (_, scrollController) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Godown Stock Audit History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: allMovements.isEmpty
                              ? const Center(
                                  child: Text('No movements recorded.'))
                              : ListView.separated(
                                  controller: scrollController,
                                  itemCount: allMovements.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, index) {
                                    final m = allMovements[index];
                                    return ListTile(
                                      title: Text(m.godownItemName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                        '${m.movementType.name} • ${dateFormatter.format(m.createdAt)}\n${m.note ?? ""}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      trailing: Text(
                                        m.quantityChanged >= 0
                                            ? '+${m.quantityChanged}'
                                            : '${m.quantityChanged}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: m.quantityChanged >= 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Add Godown Stock'),
        onPressed: _showAddStockDialog,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.amber.shade100,
            child: const Text(
              '📦 Godown Stock Pool: Completely separate from Shop Inventory. Transfer stock to Shop to make it saleable.',
              style:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search godown stock...',
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
                    onRefresh: _loadItems,
                    child: _filteredItems.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warehouse_outlined,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text(
                                      'No stock in this godown',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tap "+ Add Godown Item" to add new stock.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                            itemCount: _filteredItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                Colors.indigo.shade50,
                                            child: const Icon(Icons.warehouse,
                                                color: Colors.indigo),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                if (item.unitCost > 0)
                                                  Text(
                                                    'Cost: ₹${item.unitCost.toStringAsFixed(2)} ${item.unit != null ? "/ ${item.unit}" : ""}',
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                              Text(
                                                item.unit ?? 'units',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (item.notes != null &&
                                          item.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Notes: ${item.notes}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.indigo,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                            ),
                                            icon: const Icon(Icons.send_to_mobile,
                                                size: 16),
                                            label: const Text('Transfer to Shop'),
                                            onPressed: () =>
                                                _showTransferToShopDialog(item),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                tooltip: 'Increase Qty',
                                                icon: const Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.green),
                                                onPressed: () =>
                                                    _showAdjustQuantityDialog(
                                                        item, true),
                                              ),
                                              IconButton(
                                                tooltip: 'Decrease Qty',
                                                icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                    color: Colors.orange),
                                                onPressed: () =>
                                                    _showAdjustQuantityDialog(
                                                        item, false),
                                              ),
                                              IconButton(
                                                tooltip: 'Movement History',
                                                icon: const Icon(Icons.history,
                                                    color: Colors.blue),
                                                onPressed: () =>
                                                    _showMovementHistory(item),
                                              ),
                                              PopupMenuButton<String>(
                                                onSelected: (val) {
                                                  if (val == 'edit') {
                                                    _showEditDialog(item);
                                                  } else if (val == 'delete') {
                                                    _confirmDelete(item);
                                                  }
                                                },
                                                itemBuilder: (_) => const [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Edit Item'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete,
                                                            color: Colors.red,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Remove Stock',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
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
    );
  }
}
