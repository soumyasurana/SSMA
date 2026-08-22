import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/sale.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';
import 'package:ssma/services/pdf_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  List<Sale> _customerSales = [];
  double _pendingDues = 0;
  List<CustomerPayment> _customerPayments = [];
  bool _isGeneratingLedger = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _generateLedger() async {
    if (_isGeneratingLedger) return;
    setState(() => _isGeneratingLedger = true);
    try {
      await PDFService.generateCustomerLedgerPdf(customer: widget.customer);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ledger PDF generated")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error generating ledger PDF: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingLedger = false);
      }
    }
  }

  Future<void> _loadCustomerData() async {
    final sales = await DBService.getAllSales();

    final relevantSales = sales
        .where((sale) =>
            sale.customerUuid == widget.customer.uuid &&
            sale.saleType == SaleType.credit)
        .toList();

    double dues = relevantSales.fold(
        0.0, (sum, sale) => sum + (sale.totalAmount - sale.amountReceived));
    dues = dues.clamp(0.0, double.infinity);

    final payments = await DBService.getCustomerPaymentsByCustomerUuid(
      widget.customer.uuid,
    );

    setState(() {
      _customerSales = relevantSales;
      _pendingDues = dues;
      _customerPayments = payments;
    });
  }

  Future<void> _handlePayment(double amount) async {
    double remaining = amount;
    final sortedSales = [..._customerSales]
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final sale in sortedSales) {
      final due = sale.totalAmount - sale.amountReceived;
      if (due <= 0) continue;

      final payment = remaining >= due ? due : remaining;
      sale.amountReceived += payment;

      await DBService.updateSale(sale);

      remaining -= payment;
      if (remaining <= 0) break;
    }

    final newDue = (_pendingDues - amount).clamp(0, double.infinity);

    final payment = CustomerPayment.create(
      customerUuid: widget.customer.uuid,
      customerName: widget.customer.name,
      amountReceived: amount,
      previousDue: _pendingDues,
      newDue: newDue.toDouble(),
      date: DateTime.now(),
      deviceId: await DeviceService.getDeviceId(),
    );

    await DBService.addCustomerPayment(payment);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment recorded successfully.")),
    );

    _loadCustomerData();
  }

  void _showPaymentDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Receive Payment"),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration:
              const InputDecoration(labelText: 'Enter amount received'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount.")),
                );
                return;
              }
              if (amount > _pendingDues) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Amount cannot exceed pending dues (₹${_pendingDues.toStringAsFixed(2)})."),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _handlePayment(amount);
            },
            child: const Text("Add Payment"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer: ${customer.name}'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            tooltip: "Download Ledger PDF",
            style: IconButton.styleFrom(foregroundColor: Colors.deepOrange),
            icon: _isGeneratingLedger
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.deepOrange, strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            onPressed: _isGeneratingLedger ? null : _generateLedger,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(customer.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(customer.phone ?? 'No contact'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pending Dues',
                          style: TextStyle(fontSize: 12)),
                      Text('₹${_pendingDues.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isGeneratingLedger ? null : _generateLedger,
                    icon: _isGeneratingLedger
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: const Text("Download Ledger PDF"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange),
                  ),
                  if (_pendingDues > 0) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _showPaymentDialog,
                      icon: const Icon(Icons.currency_rupee),
                      label: const Text("Update Payment"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              const Text("Sales History",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _customerSales.isEmpty
                  ? const Center(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No credit sales found.')))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _customerSales.length,
                      itemBuilder: (context, index) {
                        final sale = _customerSales[index];
                        final pending = (sale.totalAmount -
                                sale.amountReceived)
                            .clamp(0, sale.totalAmount);

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin:
                              const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                                "Total: ₹${sale.totalAmount.toStringAsFixed(2)}"),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Received: ₹${sale.amountReceived.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        color: Colors.green)),
                                Text(
                                    "Pending: ₹${pending.toStringAsFixed(2)}",
                                    style:
                                        const TextStyle(color: Colors.red)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM yyyy – hh:mm a')
                                      .format(sale.date),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            trailing: Text("${sale.items.length} items",
                                style:
                                    const TextStyle(color: Colors.grey)),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 24),
              const Text("Payment History",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _customerPayments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No payments found.'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _customerPayments.length,
                      itemBuilder: (context, index) {
                        final p = _customerPayments[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          margin:
                              const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long,
                                color: Colors.indigo),
                            title: Text(
                                '₹${p.amountReceived.toStringAsFixed(2)} received'),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Prev Due: ₹${p.previousDue.toStringAsFixed(2)} → New: ₹${p.newDue.toStringAsFixed(2)}'),
                                Text(DateFormat('dd MMM yyyy')
                                    .format(p.date)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () async {
                                final confirm =
                                    await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title:
                                        const Text("Delete Payment?"),
                                    content: const Text(
                                        "Are you sure you want to delete this payment?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child:
                                              const Text("Cancel")),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red),
                                        child:
                                            const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await DBService
                                      .deleteCustomerPayment(
                                          p.isarId);
                                  if (!context.mounted) return;
                                  _loadCustomerData();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Payment deleted.")),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
