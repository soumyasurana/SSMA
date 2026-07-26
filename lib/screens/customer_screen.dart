import 'package:flutter/material.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/screens/customer_detail_screen.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    syncV2?.statusNotifier.addListener(_onSyncChanged);
    _searchController.addListener(() {
      _filterCustomers(_searchController.text);
    });
  }

  void _onSyncChanged() {
    if (mounted) {
      _loadCustomers();
    }
  }

  @override
  void dispose() {
    syncV2?.statusNotifier.removeListener(_onSyncChanged);
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final customers = await DBService.getCustomers();
    final allSales = await DBService.getAllSales();

    for (final customer in customers) {
      final customerSales = allSales.where(
        (sale) =>
            sale.customerUuid == customer.uuid &&
            sale.saleType == SaleType.credit,
      );

      double pending = 0.0;
      for (final sale in customerSales) {
        pending += (sale.totalAmount - sale.amountReceived).clamp(0.0, double.infinity);
      }

      customer.pendingDues = pending;
    }

    customers.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    setState(() {
      _customers = customers;
      _filteredCustomers = customers;
    });
  }

  void _filterCustomers(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(lowerQuery) ||
            (customer.phone?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    });
  }

  void _showCustomerDialog({Customer? customer}) {
    final isEdit = customer != null;

    if (isEdit) {
      _nameController.text = customer.name;
      _phoneController.text = customer.phone ?? '';
    } else {
      _nameController.clear();
      _phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'Edit Customer' : 'Add Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
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
            ElevatedButton.icon(
              icon: Icon(isEdit ? Icons.save : Icons.add),
              label: Text(isEdit ? 'Update' : 'Add'),
              onPressed: () async {
                final name = _nameController.text.trim();
                final phone = _phoneController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required.')),
                  );
                  return;
                }

                final currentCustomerUuid = isEdit ? customer.uuid : '';

                // Prevent duplicate customer names (case-insensitive)
                final existing = _customers.where((c) =>
                    c.name.toLowerCase() == name.toLowerCase() &&
                    (!isEdit || c.uuid != currentCustomerUuid));
                if (existing.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('A customer with this name already exists.')),
                  );
                  return;
                }

                if (isEdit) {
                  final editingCustomer = customer;
                  editingCustomer.name = name;
                  editingCustomer.phone = phone;
                  editingCustomer.updatedAt = DateTime.now();
                  editingCustomer.version++;

                  await DBService.updateCustomer(editingCustomer);
                } else {
                  final newCustomer = Customer.create(
                    name: name,
                    phone: phone,
                    deviceId: await DeviceService.getDeviceId(),
                  );

                  await DBService.addCustomer(newCustomer);
                }

                if (!context.mounted) return;
                Navigator.pop(context);
                _loadCustomers();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DBService.deleteCustomer(customer.uuid);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer deleted')),
        );
        await _loadCustomers();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete customer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _filteredCustomers.isEmpty
                ? const Center(child: Text('No customers found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        color: Colors.indigo.shade50,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            customer.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer.phone ?? 'No phone'),
                              Text(
                                'Pending Dues: ₹${customer.pendingDues.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCustomer(customer),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CustomerDetailScreen(customer: customer),
                              ),
                            );
                            _loadCustomers();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
    );
  }
}
