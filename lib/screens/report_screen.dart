import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/pdf_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _groupBy = 'Customer';
  bool _loading = false;

  List<Sale> _sales = [];
  List<Purchase> _purchases = [];
  List<SupplierPayment> _payments = [];
  List<Supplier> _suppliers = [];

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  Future<void> _loadData() async {
    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a valid date range.")),
      );
      return;
    }

    setState(() => _loading = true);

    final sales = await DBService.getAllSales();
    final purchases = await DBService.getAllPurchases();
    final payments = await DBService.getAllSupplierPayments();
    final suppliers = await DBService.getSuppliers();

    bool inRange(DateTime date) =>
        !date.isBefore(_fromDate!) && !date.isAfter(_toDate!);

    setState(() {
      _sales = sales.where((s) => inRange(s.date)).toList();
      _purchases = purchases.where((p) => inRange(p.date)).toList();
      _payments = payments.where((p) => inRange(p.date)).toList();
      _suppliers = suppliers;
      _loading = false;
    });
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _groupBy,
      items: ['Customer', 'Supplier', 'Product']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) {
        setState(() => _groupBy = value!);
      },
      decoration: const InputDecoration(
        labelText: 'Group By',
        border: OutlineInputBorder(),
      ),
    );
  }

  List<Widget> _buildGroupedList() {
    final List<Widget> rows = [];

    if (_groupBy == 'Customer') {
      final Map<String, double> customerTotals = {};

      for (final sale in _sales) {
        final name = sale.buyerName ?? 'Unknown Customer';
        customerTotals[name] =
            (customerTotals[name] ?? 0) + sale.totalAmount;
      }

      rows.addAll(customerTotals.entries.map(
          (e) => Text('• ${e.key}: ₹${e.value.toStringAsFixed(2)}')));
    }

    else if (_groupBy == 'Supplier') {
      final Map<String, String> supplierNameById = {
        for (final s in _suppliers) s.uuid: s.name
      };

      final Map<String, double> supplierTotals = {};

      for (final purchase in _purchases) {
        final name =
            supplierNameById[purchase.supplierUuid] ?? 'Unknown Supplier';

        supplierTotals[name] =
            (supplierTotals[name] ?? 0) + purchase.totalAmount;
      }

      rows.addAll(supplierTotals.entries.map(
          (e) => Text('• ${e.key}: ₹${e.value.toStringAsFixed(2)}')));
    }

    else if (_groupBy == 'Product') {
      final Map<String, double> productTotals = {};

      for (final sale in _sales) {
        for (final item in sale.items) {
          productTotals[item.productName] =
              (productTotals[item.productName] ?? 0) +
                  (item.quantity * item.unitPrice);
        }
      }

      rows.addAll(productTotals.entries.map(
          (e) => Text('• ${e.key}: ₹${e.value.toStringAsFixed(2)}')));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(
                _fromDate != null && _toDate != null
                    ? '${formatter.format(_fromDate!)} - ${formatter.format(_toDate!)}'
                    : 'Select Date Range',
              ),
            ),
            const SizedBox(height: 12),
            _buildDropdown(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _loadData,
                    icon: const Icon(Icons.download),
                    label: const Text('Load Data'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_fromDate != null &&
                            _toDate != null &&
                            !_loading)
                        ? () => PDFService.generateReportPdf(
                              sales: _sales,
                              purchases: _purchases,
                              payments: _payments,
                              groupBy: _groupBy,
                              fromDate: _fromDate!,
                              toDate: _toDate!,
                            )
                        : null,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView(
                  children: [
                    Text('Sales: ${_sales.length}'),
                    Text('Purchases: ${_purchases.length}'),
                    Text('Payments: ${_payments.length}'),
                    const SizedBox(height: 8),
                    ..._buildGroupedList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
