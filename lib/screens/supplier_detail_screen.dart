import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';
import 'package:ssma/services/pdf_service.dart';

class SupplierDetailScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  List<Purchase> _purchases = [];
  List<SupplierPayment> _payments = [];

  DateTime? _fromDate;
  DateTime? _toDate;

  double get totalPurchased =>
      _purchases.fold(0.0, (sum, p) => sum + p.totalAmount);
  double get totalPaid => _payments.fold(0.0, (sum, p) => sum + p.amount);
  double get balanceDue => totalPurchased - totalPaid;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    // no persistent controllers here, but keep override for future additions
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final purchases =
        await DBService.getPurchasesBySupplier(widget.supplier.uuid);
    final payments =
        await DBService.getSupplierPayments(widget.supplier.uuid);
    if (!mounted) return;
    setState(() {
      _purchases = purchases;
      _payments = payments;
    });
  }

  void _showAddPaymentDialog() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
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
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount.')),
                  );
                  return;
                }

                if (amount > balanceDue) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Amount cannot exceed balance due (₹${balanceDue.toStringAsFixed(2)}).',
                      ),
                    ),
                  );
                  return;
                }

                final payment = SupplierPayment.create(
                  supplierUuid: widget.supplier.uuid,
                  amount: amount,
                  date: DateTime.now(),
                  note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                  deviceId: await DeviceService.getDeviceId(),
                );

                await DBService.addSupplierPayment(payment);
                if (context.mounted) Navigator.pop(context);
                await _loadDetails();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: (_fromDate != null && _toDate != null)
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  Future<void> _downloadStatement() async {
    if (_fromDate == null || _toDate == null) return;
    final filteredPurchases = _purchases
        .where((p) =>
            !p.date.isBefore(_fromDate!) &&
            !p.date.isAfter(_toDate!))
        .toList();
    final filteredPayments = _payments
        .where((p) =>
            !p.date.isBefore(_fromDate!) &&
            !p.date.isAfter(_toDate!))
        .toList();

    await PDFService.generateSupplierStatement(
      supplier: widget.supplier,
      purchases: filteredPurchases,
      payments: filteredPayments,
      startDate: _fromDate!,
      endDate: _toDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(widget.supplier.name)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListTile(
                  title: const Text('Account Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Total Purchased: ₹${totalPurchased.toStringAsFixed(2)}'),
                      Text('Total Paid: ₹${totalPaid.toStringAsFixed(2)}'),
                      Text(
                        'Balance Due: ₹${balanceDue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: balanceDue > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_card, size: 28),
                    tooltip: 'Add Payment',
                    onPressed: _showAddPaymentDialog,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      (_fromDate == null || _toDate == null)
                          ? 'Select Date Range'
                          : '${dateFormatter.format(_fromDate!)} → ${dateFormatter.format(_toDate!)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: (_fromDate != null && _toDate != null)
                      ? _downloadStatement
                      : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Download Statement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Purchase History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _purchases.isEmpty
                  ? const Center(child: Text('No purchases found'))
                  : ListView.builder(
                      itemCount: _purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = _purchases[index];
                        final itemDetails = purchase.items
                            .map((e) => '${e.productName} (x${e.quantity})')
                            .join(', ');
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.shopping_bag_outlined),
                            title: Text(
                              '₹${purchase.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '$itemDetails • ${dateFormatter.format(purchase.date)}',
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: _payments.isEmpty
                  ? const Center(child: Text('No payments yet'))
                  : ListView.builder(
                      itemCount: _payments.length,
                      itemBuilder: (context, index) {
                        final payment = _payments[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.payments_outlined),
                            title: Text(
                              '₹${payment.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${payment.note ?? "No note"} • ${dateFormatter.format(payment.date)}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
