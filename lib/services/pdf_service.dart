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
import 'package:ssma/utils/sale_metadata.dart';

class PDFService {
  static bool generateFiles = true;
  static bool openGeneratedFiles = true;

  static Future<void> generateInvoice(Sale sale) async {
    if (!generateFiles) return;

    final pdf = pw.Document();
    final font =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final boldFont =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
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
      final imageBytes = await rootBundle.load('assets/logo_app.png');
      logo = pw.MemoryImage(imageBytes.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    // ── helper styles ──────────────────────────────────────────────────────
    final headerStyle =
        pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.white);
    final cellStyle = pw.TextStyle(font: font, fontSize: 11);
    final labelStyle =
        pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700);
    final valueStyle = pw.TextStyle(font: boldFont, fontSize: 12);

    const primaryColor = PdfColor.fromInt(0xFF1565C0);
    const accentColor = PdfColor.fromInt(0xFFE3F2FD);
    const dividerColor = PdfColor.fromInt(0xFFBBDEFB);
    final metadata = SaleMetadata.parse(sale.comment);

    // ── parse extra charges from comment ──────────────────────────────────
    final List<MapEntry<String, double>> extraCharges = [];
    String? cleanComment = metadata.visibleComment;
    if (cleanComment != null && cleanComment.contains('Charges:')) {
      final parts = cleanComment.split(' | Charges: ');
      cleanComment = parts[0].isEmpty ? null : parts[0];
      if (parts.length > 1) {
        for (final entry in parts[1].split(', ')) {
          final kv = entry.split(': Rs.');
          if (kv.length == 2) {
            final amount = double.tryParse(kv[1]);
            if (amount != null) extraCharges.add(MapEntry(kv[0], amount));
          }
        }
      }
    }
    // also handle comment that starts directly with "Charges:"
    if (cleanComment != null &&
        cleanComment.startsWith('Charges: ') &&
        extraCharges.isEmpty) {
      final chargesStr = cleanComment.replaceFirst('Charges: ', '');
      cleanComment = null;
      for (final entry in chargesStr.split(', ')) {
        final kv = entry.split(': Rs.');
        if (kv.length == 2) {
          final amount = double.tryParse(kv[1]);
          if (amount != null) extraCharges.add(MapEntry(kv[0], amount));
        }
      }
    }

    // ── build item rows with serial numbers ────────────────────────────────
    final tableData = sale.items.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final item = entry.value;
      return [
        '$idx',
        item.productName,
        '${item.quantity}',
        item.unitPrice.toStringAsFixed(2),
        (item.unitPrice * item.quantity).toStringAsFixed(2),
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),

        // ── HEADER ────────────────────────────────────────────────────────
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null)
                  pw.Image(logo, width: 80, height: 60, fit: pw.BoxFit.contain),
                if (logo != null) pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Surana Electronix',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 22,
                              color: primaryColor)),
                      pw.Text('Shop No. 250',
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 10,
                              color: PdfColors.grey700)),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: const pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text('INVOICE',
                      style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 16,
                          color: PdfColors.white)),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Container(height: 2, color: primaryColor),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 9,
                              color: primaryColor)),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        (sale.buyerName != null && sale.buyerName!.isNotEmpty)
                            ? sale.buyerName!
                            : 'Walk-in Customer',
                        style: pw.TextStyle(font: boldFont, fontSize: 13),
                      ),
                      if (sale.buyerContact != null &&
                          sale.buyerContact!.isNotEmpty)
                        pw.Text(sale.buyerContact!,
                            style: pw.TextStyle(
                                font: font,
                                fontSize: 11,
                                color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('DATE',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 9,
                              color: primaryColor)),
                      pw.SizedBox(height: 3),
                      pw.Text(formatter.format(sale.date),
                          style: pw.TextStyle(font: font, fontSize: 11)),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: sale.saleType == SaleType.credit
                              ? const PdfColor.fromInt(0xFFFF6F00)
                              : const PdfColor.fromInt(0xFF2E7D32),
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          sale.saleType == SaleType.credit ? 'CREDIT' : 'CASH',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 10,
                              color: PdfColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
          ],
        ),

        // ── FOOTER ────────────────────────────────────────────────────────
        footer: (context) => pw.Column(
          children: [
            pw.Container(height: 1, color: dividerColor),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Surana Electronix — Thank you for your business!',
                    style: pw.TextStyle(
                        font: font, fontSize: 9, color: PdfColors.grey600)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(
                        font: font, fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),

        // ── BODY ──────────────────────────────────────────────────────────
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Item', 'Qty', 'Rate (Rs.)', 'Amount (Rs.)'],
            data: tableData,
            border: pw.TableBorder.all(color: dividerColor, width: 0.5),
            headerStyle: headerStyle,
            headerDecoration: const pw.BoxDecoration(color: primaryColor),
            cellStyle: cellStyle,
            cellHeight: 24,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 12),

          // Summary Section
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 240,
              decoration: pw.BoxDecoration(
                border: pw.TableBorder.all(color: dividerColor, width: 0.5),
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Items Subtotal:', style: labelStyle),
                        pw.Text('Rs. ${sale.totalAmount.toStringAsFixed(2)}',
                            style: valueStyle),
                      ],
                    ),
                  ),

                  // Extra Charges breakdown
                  if (extraCharges.isNotEmpty) ...[
                    pw.Container(height: 0.5, color: dividerColor),
                    ...extraCharges.map(
                      (charge) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('+ ${charge.key}:', style: labelStyle),
                            pw.Text('Rs. ${charge.value.toStringAsFixed(2)}',
                                style: valueStyle),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (previousBalance > 0) ...[
                    pw.Container(height: 0.5, color: dividerColor),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Previous Due:', style: labelStyle),
                          pw.Text('Rs. ${previousBalance.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 11,
                                  color: PdfColors.red800)),
                        ],
                      ),
                    ),
                  ],

                  if (sale.amountReceived > 0) ...[
                    pw.Container(height: 0.5, color: dividerColor),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Amount Paid:', style: labelStyle),
                          pw.Text(
                              'Rs. ${sale.amountReceived.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 12,
                                  color: PdfColors.green800)),
                        ],
                      ),
                    ),
                  ],

                  if (metadata.payments.isNotEmpty) ...[
                    pw.Container(height: 0.5, color: dividerColor),
                    ...metadata.payments.map(
                      (payment) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(payment.method, style: labelStyle),
                            pw.Text('Rs. ${payment.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 11,
                                    color: PdfColors.green800)),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Net Due / Grand Total
                  pw.Container(height: 0.5, color: dividerColor),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: const pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.only(
                        bottomLeft: pw.Radius.circular(5),
                        bottomRight: pw.Radius.circular(5),
                      ),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          sale.saleType == SaleType.credit
                              ? 'Net Due:'
                              : 'Grand Total:',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 13,
                              color: PdfColors.white),
                        ),
                        pw.Text(
                          'Rs. ${(sale.totalAmount + previousBalance - sale.amountReceived).toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 13,
                              color: PdfColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 16),

          // ── Comment (clean, without charges string) ───────────────────
          if (cleanComment != null && cleanComment.isNotEmpty) ...[
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text('Notes: $cleanComment',
                  style: pw.TextStyle(
                      font: font, fontSize: 10, color: PdfColors.grey800)),
            ),
            pw.SizedBox(height: 12),
          ],

          pw.Spacer(),

          // Footer
          pw.Divider(color: dividerColor),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Thank you for your business!',
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 10, color: primaryColor)),
              pw.Text('Page 1 of 1', style: labelStyle),
            ],
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file =
        File('${dir.path}/Invoice_${sale.isarId}_${sale.uuid.substring(0, 6)}.pdf');
    await file.writeAsBytes(await pdf.save());
    if (openGeneratedFiles) {
      await OpenFilex.open(file.path);
    }
  }

  // =========================================================================
  // generateSupplierStatement
  // =========================================================================
  static Future<void> generateSupplierStatement({
    required Supplier supplier,
    required List<Purchase> purchases,
    required List<SupplierPayment> payments,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    pw.Font font;
    pw.Font boldFont;
    try {
      font = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
      boldFont = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    } catch (_) {
      font = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }
    final formatter = DateFormat('dd MMM yyyy');

    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    double totalPurchase = 0;
    double totalPayment = 0;

    for (final p in purchases) {
      if (!p.date.isBefore(normalizedStart) && !p.date.isAfter(normalizedEnd)) {
        totalPurchase += p.totalAmount;
      }
    }
    for (final pay in payments) {
      if (!pay.date.isBefore(normalizedStart) && !pay.date.isAfter(normalizedEnd)) {
        totalPayment += pay.amount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text('Supplier Account Statement',
              style: pw.TextStyle(font: boldFont, fontSize: 20)),
          pw.SizedBox(height: 8),
          pw.Text('Supplier: ${supplier.name}',
              style: pw.TextStyle(font: font)),
          pw.Text('Contact: ${supplier.contact}',
              style: pw.TextStyle(font: font)),
          if ((supplier.address ?? '').isNotEmpty)
            pw.Text('Address: ${supplier.address}',
                style: pw.TextStyle(font: font)),
          pw.SizedBox(height: 12),
          pw.Text(
            'Period: ${formatter.format(startDate)} - ${formatter.format(endDate)}',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text('Purchases:',
              style: pw.TextStyle(font: boldFont, fontSize: 14)),
          if (purchases.isEmpty)
            pw.Text('No purchases during this period.',
                style: pw.TextStyle(font: font))
          else
            pw.Column(
              children: purchases
                  .where((p) =>
                      !p.date.isBefore(normalizedStart) &&
                      !p.date.isAfter(normalizedEnd))
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
          pw.Text('Payments Made:',
              style: pw.TextStyle(font: boldFont, fontSize: 14)),
          if (payments.isEmpty)
            pw.Text('No payments during this period.',
                style: pw.TextStyle(font: font))
          else
            pw.Column(
              children: payments
                  .where((p) =>
                      !p.date.isBefore(normalizedStart) &&
                      !p.date.isAfter(normalizedEnd))
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
          pw.Text('Total Purchased: ${totalPurchase.toStringAsFixed(2)}',
              style: pw.TextStyle(font: font)),
          pw.Text('Total Paid: ${totalPayment.toStringAsFixed(2)}',
              style: pw.TextStyle(font: font)),
          pw.Text(
              'Balance: ${(totalPurchase - totalPayment).toStringAsFixed(2)}',
              style: pw.TextStyle(font: boldFont, fontSize: 13)),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/Supplier_Statement_${supplier.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    if (openGeneratedFiles) {
      await OpenFilex.open(file.path);
    }
  }

  // =========================================================================
  // generateReportPdf
  // =========================================================================
  static Future<void> generateReportPdf({
    required List<Sale> sales,
    required List<Purchase> purchases,
    required List<SupplierPayment> payments,
    required String groupBy,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final pdf = pw.Document();
    final boldFont =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    final formatter = DateFormat('dd MMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Business Report',
              style: pw.TextStyle(font: boldFont, fontSize: 24)),
          pw.SizedBox(height: 12),
          pw.Text('From: ${formatter.format(fromDate)}'),
          pw.Text('To: ${formatter.format(toDate)}'),
          pw.SizedBox(height: 16),
          pw.Text('Sales:', style: pw.TextStyle(font: boldFont)),
          ...sales.map((s) => pw.Text(
              '• ${s.buyerName ?? "Customer"} - ${s.totalAmount.toStringAsFixed(2)}')),
          pw.SizedBox(height: 12),
          pw.Text('Purchases:', style: pw.TextStyle(font: boldFont)),
          ...purchases
              .map((p) => pw.Text('• ${p.totalAmount.toStringAsFixed(2)}')),
          pw.SizedBox(height: 12),
          pw.Text('Supplier Payments:', style: pw.TextStyle(font: boldFont)),
          ...payments.map((p) => pw.Text(
              '• ${p.amount.toStringAsFixed(2)} - ${p.note ?? "No note"}')),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/Business_Report_${fromDate.millisecondsSinceEpoch}_${toDate.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    if (openGeneratedFiles) {
      await OpenFilex.open(file.path);
    }
  }

  // =========================================================================
  // generatePaymentReceipt
  // =========================================================================
  static Future<void> generatePaymentReceipt(CustomerPayment payment) async {
    final pdf = pw.Document();
    final font =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final boldFont =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Payment Receipt',
                style: pw.TextStyle(font: boldFont, fontSize: 20)),
            pw.SizedBox(height: 12),
            pw.Text('Customer: ${payment.customerName}',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Text('Date: ${formatter.format(payment.date)}',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 16),
            pw.Text('Previous Due: ${payment.previousDue.toStringAsFixed(2)}',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Text(
                'Amount Received: ${payment.amountReceived.toStringAsFixed(2)}',
                style: pw.TextStyle(font: boldFont, fontSize: 14)),
            pw.Text('New Due: ${payment.newDue.toStringAsFixed(2)}',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.Text('Thank you for your payment.',
                style:
                    pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic)),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 30),
                  pw.Text('Authorized Signature',
                      style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Container(width: 100, child: pw.Divider()),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file =
        File('${dir.path}/Receipt_${payment.date.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    if (openGeneratedFiles) {
      await OpenFilex.open(file.path);
    }
  }
}
