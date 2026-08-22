import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/screens/new_sale_screen.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/pdf_service.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart' show syncV2;

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  List<Sale> _sales = [];
  List<Sale> _filteredSales = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _pdfGeneratingSales = {}; // to track ongoing PDF generations per sale

  @override
  void initState() {
    super.initState();
    _loadSales();
    syncV2?.statusNotifier.addListener(_onSyncChanged);
    _searchController.addListener(() {
      _filterSales(_searchController.text);
    });
  }

  void _onSyncChanged() {
    if (mounted) {
      _loadSales();
    }
  }

  @override
  void dispose() {
    syncV2?.statusNotifier.removeListener(_onSyncChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    final sales = await DBService.getAllSales();
    setState(() {
      _sales = sales;
      _filteredSales = sales;
    });
  }

  void _filterSales(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredSales = _sales.where((sale) {
        final buyerMatch = (sale.buyerName?.toLowerCase() ?? '').contains(lowerQuery) ||
            (sale.buyerContact?.toLowerCase() ?? '').contains(lowerQuery);
        final productMatch = sale.items.any(
          (item) => item.productName.toLowerCase().contains(lowerQuery),
        );
        return buyerMatch || productMatch;
      }).toList();
    });
  }

void _confirmDelete(Sale sale) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Delete Sale"),
      content: const Text("Are you sure you want to delete this sale record?\nThis will restore product stock."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            await DBService.deleteSaleAndRestoreStock(sale.uuid);
            if (!context.mounted) return;
            Navigator.pop(context);
            _loadSales();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sale deleted and stock restored.")),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Delete"),
        ),
      ],
    ),
  );
}


  void _navigateToEditSale(Sale sale) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewSaleScreen(existingSale: sale)),
    );
    _loadSales();
  }

  void _showUpdatePaymentDialog(Sale sale) {
    final pending = sale.totalAmount - sale.amountReceived;

    if (pending <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No pending amount for this sale.")),
      );
      return;
    }

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Payment"),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Enter amount received",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim()) ?? 0;

              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid amount")),
                );
                return;
              }
              if (amount > pending) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Cannot receive more than pending ₹${pending.toStringAsFixed(2)}",
                    ),
                  ),
                );
                return;
              }

              await DBService.updateSalePayment(
                saleUuid: sale.uuid,
                newAmountReceived: sale.amountReceived + amount,
              );

              if (!context.mounted) return;
              Navigator.pop(context);
              _loadSales();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Payment updated successfully")),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

Future<void> _generateInvoice(Sale sale) async {
  if (!mounted) return;

  setState(() => _pdfGeneratingSales.add(sale.uuid));

  try {
    await PDFService.generateInvoice(sale);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice generated")),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _pdfGeneratingSales.remove(sale.uuid));
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy – hh:mm a');
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, contact, or product...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.indigo.shade50,
              ),
            ),
          ),
          Expanded(
            child: _filteredSales.isEmpty
                ? const Center(
                    child: Text(
                      'No matching sales found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = _filteredSales[index];
                      final received = sale.amountReceived;
                      final total = sale.totalAmount;
                      final pending = (total - received).clamp(0, total);
                      final isGenerating = _pdfGeneratingSales.contains(sale.uuid);

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sale.buyerName ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      sale.saleType == SaleType.cash
                                          ? 'Cash Sale'
                                          : 'Customer Sale',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: sale.saleType == SaleType.cash
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    labelStyle: TextStyle(
                                      color: sale.saleType == SaleType.cash
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Contact: ${sale.buyerContact ?? 'N/A'}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text("Items: ${sale.items.length}"),
                              const SizedBox(height: 4),
                              Text("Total: ${currencyFormatter.format(total)}",
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text("Received: ${currencyFormatter.format(received)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: received >= total ? Colors.green : null,
                                  )),
                              Text("Pending: ${currencyFormatter.format(pending)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: pending > 0 ? Colors.red : Colors.green,
                                  )),
                              Text(
                                "Date: ${dateFormatter.format(sale.date)}",
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    tooltip: "Generate Invoice PDF",
                                    icon: isGenerating
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.picture_as_pdf, color: Colors.green),
                                    onPressed: isGenerating ? null : () => _generateInvoice(sale),
                                  ),
                                  if (sale.saleType == SaleType.credit)
                                    IconButton(
                                      tooltip: "Update Payment",
                                      icon: const Icon(Icons.payments, color: Colors.purple),
                                      onPressed: () => _showUpdatePaymentDialog(sale),
                                    ),
                                  IconButton(
                                    tooltip: "Edit Sale",
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () => _navigateToEditSale(sale),
                                  ),
                                  IconButton(
                                    tooltip: "Delete Sale",
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(sale),
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
        ],
      ),
    );
  }
}
