import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssma/models/sale.dart';
import 'package:open_filex/open_filex.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/supplier_payment.dart';

class PDFService {
  static Future<void> generateInvoice(Sale sale) async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final boldFont = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    double previousBalance = 0;

    if (sale.saleType == SaleType.credit) {
      final allSales = await DBService.getAllSales();
      final customerSales = allSales.where((s) =>
          s.buyerName == sale.buyerName &&
          s.buyerContact == sale.buyerContact &&
          s.saleType == SaleType.credit &&
          s.date.isBefore(sale.date) &&
          s.uuid != sale.uuid);
      for (final s in customerSales) {
        previousBalance += (s.totalAmount - s.amountReceived);
      }
    }

    pw.ImageProvider? logo;
    try {
      final imageBytes = await rootBundle.load('assets/logo.png');
      logo = pw.MemoryImage(imageBytes.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ABC', style: pw.TextStyle(font: boldFont, fontSize: 18)),
                    pw.Text('GSTIN: 27ABCDE1234F1Z5', style: pw.TextStyle(font: font, fontSize: 11)),
                    pw.Text('Phone: +91-ABCD', style: pw.TextStyle(font: font, fontSize: 11)),
                    pw.Text('Address : CDEF', style: pw.TextStyle(font: font, fontSize: 11)),
                  ],
                ),
                if (logo != null)
                  pw.Container(
                    height: 60,
                    width: 60,
                    child: pw.Image(logo),
                  ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('INVOICE', style: pw.TextStyle(font: boldFont, fontSize: 24)),
                pw.Text('Date: ${formatter.format(sale.date)}', style: pw.TextStyle(font: font)),
              ],
            ),
            pw.SizedBox(height: 12),

            if ((sale.buyerName?.isNotEmpty ?? false) || (sale.buyerContact?.isNotEmpty ?? false))
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (sale.buyerName?.isNotEmpty ?? false)
                      pw.Text('Buyer: ${sale.buyerName}', style: pw.TextStyle(font: font)),
                    if (sale.buyerContact?.isNotEmpty ?? false)
                      pw.Text('Contact: ${sale.buyerContact}', style: pw.TextStyle(font: font)),
                  ],
                ),
              ),

            pw.Table.fromTextArray(
              headers: ['Product', 'Qty', 'Rate', 'Total'],
              data: sale.items.map((item) {
                return [
                  item.productName,
                  '${item.quantity}',
                  (item.unitPrice.toStringAsFixed(2)),
                  ((item.unitPrice * item.quantity).toStringAsFixed(2)),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(font: boldFont, fontSize: 12),
              cellStyle: pw.TextStyle(font: font, fontSize: 11),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
            ),

            if (sale.comment != null && sale.comment!.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 16),
                child: pw.Text(
                  'Comment: ${sale.comment}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            pw.SizedBox(height: 20),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (sale.saleType == SaleType.credit && previousBalance > 0)
                    pw.Text('Previous Balance: ${previousBalance.toStringAsFixed(2)}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Text('Current Bill: ${sale.totalAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: font, fontSize: 12)),
                  if (sale.saleType == SaleType.credit && previousBalance > 0)
                    pw.Divider(),
                  if (sale.saleType == SaleType.credit && previousBalance > 0)
                    pw.Text(
                      'Total Outstanding: ${(sale.totalAmount + previousBalance).toStringAsFixed(2)}',
                      style: pw.TextStyle(font: boldFont, fontSize: 14),
                    ),
                ],
              ),
            ),

            pw.Spacer(),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 30),
                  pw.Text('Authorized Signature', style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Container(width: 120, child: pw.Divider()),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Invoice_${sale.date.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  static Future<void> generateSupplierStatement({
    required Supplier supplier,
    required List<Purchase> purchases,
    required List<SupplierPayment> payments,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final boldFont = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    final formatter = DateFormat('dd MMM yyyy');

    double totalPurchase = 0;
    double totalPayment = 0;

    for (final p in purchases) {
      if (p.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          p.date.isBefore(endDate.add(const Duration(days: 1)))) {
        totalPurchase += p.totalAmount;
      }
    }
    for (final pay in payments) {
      if (pay.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          pay.date.isBefore(endDate.add(const Duration(days: 1)))) {
        totalPayment += pay.amount;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Supplier Account Statement', style: pw.TextStyle(font: boldFont, fontSize: 20)),
            pw.SizedBox(height: 8),
            pw.Text('Supplier: ${supplier.name}', style: pw.TextStyle(font: font)),
            pw.Text('Contact: ${supplier.contact}', style: pw.TextStyle(font: font)),
            if ((supplier.address ?? '').isNotEmpty)
              pw.Text('Address: ${supplier.address}', style: pw.TextStyle(font: font)),
            pw.SizedBox(height: 12),
            pw.Text('Period: ${formatter.format(startDate)} - ${formatter.format(endDate)}',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Divider(),
            pw.SizedBox(height: 8),

            pw.Text('Purchases:', style: pw.TextStyle(font: boldFont, fontSize: 14)),
            if (purchases.isEmpty)
              pw.Text('No purchases during this period.', style: pw.TextStyle(font: font))
            else
              pw.Column(
                children: purchases
                    .where((p) =>
                        p.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                        p.date.isBefore(endDate.add(const Duration(days: 1))))
                    .map((purchase) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '• ${formatter.format(purchase.date)} - ${purchase.totalAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(font: font),
                      ),
                      pw.Wrap(
                        children: purchase.items.map((item) {
                          return pw.Text(
                            '   - ${item.productName} x${item.quantity} @ ${item.purchasePrice.toStringAsFixed(2)}',
                            style: pw.TextStyle(font: font, fontSize: 11),
                          );
                        }).toList(),
                      ),
                      pw.SizedBox(height: 6),
                    ],
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 16),

            pw.Text('Payments Made:', style: pw.TextStyle(font: boldFont, fontSize: 14)),
            if (payments.isEmpty)
              pw.Text('No payments during this period.', style: pw.TextStyle(font: font))
            else
              pw.Column(
                children: payments
                    .where((p) =>
                        p.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                        p.date.isBefore(endDate.add(const Duration(days: 1))))
                    .map((payment) {
                  return pw.Text(
                    '• ${formatter.format(payment.date)} - ${payment.amount.toStringAsFixed(2)} (${payment.note ?? "No note"})',
                    style: pw.TextStyle(font: font),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text('Summary', style: pw.TextStyle(font: boldFont, fontSize: 14)),
            pw.Text('Total Purchased: ${totalPurchase.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
            pw.Text('Total Paid: ${totalPayment.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
            pw.Text('Balance: ${(totalPurchase - totalPayment).toStringAsFixed(2)}',
                style: pw.TextStyle(font: boldFont, fontSize: 13)),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Supplier_Statement_${supplier.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  static Future<void> generateReportPdf({
    required List<Sale> sales,
    required List<Purchase> purchases,
    required List<SupplierPayment> payments,
    required String groupBy,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final boldFont = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    final formatter = DateFormat('dd MMM yyyy');

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Business Report', style: pw.TextStyle(font: boldFont, fontSize: 24)),
            pw.SizedBox(height: 12),
            pw.Text('From: ${formatter.format(fromDate)}'),
            pw.Text('To: ${formatter.format(toDate)}'),
            pw.SizedBox(height: 16),
            pw.Text('Sales:', style: pw.TextStyle(font: boldFont)),
            ...sales.map((s) => pw.Text('• ${s.buyerName ?? "Customer"} - ${s.totalAmount.toStringAsFixed(2)}')),
            pw.SizedBox(height: 12),
            pw.Text('Purchases:', style: pw.TextStyle(font: boldFont)),
            ...purchases.map((p) => pw.Text('• ${p.totalAmount.toStringAsFixed(2)}')),
            pw.SizedBox(height: 12),
            pw.Text('Supplier Payments:', style: pw.TextStyle(font: boldFont)),
            ...payments.map((p) => pw.Text('• ${p.amount.toStringAsFixed(2)} - ${p.note ?? "No note"}')),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Business_Report_${fromDate.millisecondsSinceEpoch}_${toDate.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  static Future<void> generatePaymentReceipt(CustomerPayment payment) async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final boldFont = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Payment Receipt', style: pw.TextStyle(font: boldFont, fontSize: 20)),
            pw.SizedBox(height: 12),
            pw.Text('Customer: ${payment.customerName}', style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Text('Date: ${formatter.format(payment.date)}', style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 16),
            pw.Text('Previous Due: ${payment.previousDue.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Text('Amount Received: ${payment.amountReceived.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 14)),
            pw.Text('New Due: ${payment.newDue.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.Text('Thank you for your payment.', style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic)),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 30),
                  pw.Text('Authorized Signature', style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Container(width: 100, child: pw.Divider()),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Receipt_${payment.date.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }
}
