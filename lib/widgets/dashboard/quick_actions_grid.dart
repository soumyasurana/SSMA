import 'package:flutter/material.dart';
import 'package:ssma/screens/new_sale_screen.dart';
import 'package:ssma/screens/inventory_screen.dart';
import 'package:ssma/screens/sales_history_screen.dart';
import 'package:ssma/screens/customer_screen.dart';
import 'package:ssma/screens/supplier_screen.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onRefreshNeeded;

  const QuickActionsGrid({super.key, this.onRefreshNeeded});

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }

                final customer = Customer.create(
                  name: name,
                  phone: phone.isEmpty ? null : phone,
                  deviceId: syncV2?.deviceId ?? 'unknown',
                );

                await DBService.addCustomer(customer);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Customer added successfully')),
                  );
                  if (onRefreshNeeded != null) onRefreshNeeded!();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final purchasePriceController = TextEditingController();
    final salePriceController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: purchasePriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Purchase Price *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: salePriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Selling Price *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initial Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final purchasePrice = double.tryParse(purchasePriceController.text.trim()) ?? 0.0;
                final salePrice = double.tryParse(salePriceController.text.trim()) ?? 0.0;
                final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }

                final product = Product.create(
                  name: name,
                  purchasePrice: purchasePrice,
                  salePrice: salePrice,
                  quantity: quantity,
                  deviceId: syncV2?.deviceId ?? 'unknown',
                );

                await DBService.addProduct(product);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product added successfully')),
                  );
                  if (onRefreshNeeded != null) onRefreshNeeded!();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.blueGrey[800],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Prominent New Sale Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewSaleScreen()),
              );
              if (onRefreshNeeded != null) onRefreshNeeded!();
            },
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            label: const Text(
              'NEW SALE (POS)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Other quick actions in a grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: [
            _buildActionButton(
              context,
              icon: Icons.person_add_alt_1_outlined,
              label: 'Add Customer',
              onTap: () => _showAddCustomerDialog(context),
              isDark: isDark,
            ),
            _buildActionButton(
              context,
              icon: Icons.add_box_outlined,
              label: 'Add Item',
              onTap: () => _showAddItemDialog(context),
              isDark: isDark,
            ),
            _buildActionButton(
              context,
              icon: Icons.inventory_2_outlined,
              label: 'Inventory',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryScreen()),
                );
                if (onRefreshNeeded != null) onRefreshNeeded!();
              },
              isDark: isDark,
            ),
            _buildActionButton(
              context,
              icon: Icons.history,
              label: 'Sales History',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
                );
                if (onRefreshNeeded != null) onRefreshNeeded!();
              },
              isDark: isDark,
            ),
            _buildActionButton(
              context,
              icon: Icons.people_outline,
              label: 'Receivables',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerScreen()),
                );
                if (onRefreshNeeded != null) onRefreshNeeded!();
              },
              isDark: isDark,
            ),
            _buildActionButton(
              context,
              icon: Icons.local_shipping_outlined,
              label: 'Payables',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupplierScreen()),
                );
                if (onRefreshNeeded != null) onRefreshNeeded!();
              },
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.indigo,
                size: 20,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[300] : Colors.blueGrey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
