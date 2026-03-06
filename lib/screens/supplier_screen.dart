import 'package:flutter/material.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/screens/supplier_detail_screen.dart';
import 'package:ssma/screens/new_purchase_screen.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  List<Supplier> _suppliers = [];
  List<Supplier> _filteredSuppliers = [];
  Map<String, double> _balances = {};

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSuppliers);
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    final suppliers = await DBService.getAllSuppliers();
    final Map<String, double> balances = {};

    for (final s in suppliers) {
      final purchases = await DBService.getPurchasesBySupplier(s.uuid);
      final payments = await DBService.getSupplierPayments(s.uuid);
      final totalPurchased = purchases.fold(
          0.0, (sum, p) => sum + p.totalAmount);
      final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
      balances[s.uuid] = totalPurchased - totalPaid;
    }
    if (!mounted) return; 
    setState(() {
      _suppliers = suppliers;
      _filterSuppliers(); // filter after load
      _balances = balances;
      _loading = false;
    });
  }

  void _filterSuppliers() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredSuppliers = List.from(_suppliers);
      } else {
        _filteredSuppliers = _suppliers.where((s) {
          final nameMatch = s.name.toLowerCase().contains(q);
          final contactMatch = s.contact.toLowerCase().contains(q);
          return nameMatch || contactMatch;
        }).toList();
      }
    });
  }

  Future<void> _addSupplier() async {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final address = _addressController.text.trim();
    if (name.isEmpty || contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Contact are required')),
      );
      return;
    }

    // Prevent duplicate suppliers (same name + contact, case-insensitive)
    final existing = _suppliers.where((s) =>
        s.name.toLowerCase() == name.toLowerCase() &&
        s.contact.toLowerCase() == contact.toLowerCase());
    if (existing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A supplier with this name and contact already exists')),
      );
      return;
    }

    final supplier = Supplier.create(
      name: name,
      contact: contact,
      address: address.isEmpty ? null : address,
      deviceId: await DeviceService.getDeviceId(),
    );
    await DBService.addSupplier(supplier);
    _nameController.clear();
    _contactController.clear();
    _addressController.clear();
    await _loadSuppliers();
  }

  Future<void> _openDetail(Supplier supplier) async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplier: supplier)),
    );
    if (mounted) {
      await _loadSuppliers();
    }
  }

  Future<void> _addPurchase(Supplier supplier) async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (_) => NewPurchaseScreen(supplier: supplier)),
    );
    if (mounted) {
      await _loadSuppliers();
    }
  }

  void _editSupplierDialog(Supplier supplier) {
    _nameController.text = supplier.name;
    _contactController.text = supplier.contact;
    _addressController.text = supplier.address ?? "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: _contactController, decoration: const InputDecoration(labelText: 'Contact'), keyboardType: TextInputType.phone),
              TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address')),
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
              final name = _nameController.text.trim();
              final contact = _contactController.text.trim();
              final address = _addressController.text.trim();
              if (name.isEmpty || contact.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Contact are required')),
                );
                return;
              }

              // Prevent duplicate suppliers on edit (ignore current supplier)
              final existing = _suppliers.where((s) =>
                  s.uuid != supplier.uuid &&
                  s.name.toLowerCase() == name.toLowerCase() &&
                  s.contact.toLowerCase() == contact.toLowerCase());
              if (existing.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Another supplier with this name and contact already exists')),
                );
                return;
              }
              supplier.name = name;
              supplier.contact = contact;
              supplier.address = address.isEmpty ? null : address;
              await DBService.updateSupplier(supplier);
              Navigator.pop(context);
              _nameController.clear();
              _contactController.clear();
              _addressController.clear();
              await _loadSuppliers();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSupplier(Supplier supplier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete "${supplier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DBService.deleteSupplier(supplier.uuid);
              Navigator.pop(context);
              await _loadSuppliers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supplier Records")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: _contactController, decoration: const InputDecoration(labelText: 'Contact')),
                    TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address')),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _addSupplier,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Supplier'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search supplier...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSuppliers.isEmpty
                ? const Center(child: Text('No suppliers found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _filteredSuppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = _filteredSuppliers[index];
                      final balance = _balances[supplier.uuid] ?? 0.0;
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            supplier.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(supplier.contact),
                              if ((supplier.address ?? "").isNotEmpty) Text(supplier.address ?? ""),
                              const SizedBox(height: 4),
                              Text(
                                'Balance Due: ₹${balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: balance > 0 ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () => _openDetail(supplier),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit Supplier',
                                onPressed: () => _editSupplierDialog(supplier),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Supplier',
                                onPressed: () => _confirmDeleteSupplier(supplier),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                tooltip: 'Add Purchase',
                                onPressed: () => _addPurchase(supplier),
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
    );
  }
}
