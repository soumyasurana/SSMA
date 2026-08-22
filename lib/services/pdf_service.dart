import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssma/models/sale.dart';
import 'package:open_filex/open_filex.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/models/customer.dart';
import 'package:ssma/models/customer_payment.dart';
import 'package:ssma/models/supplier.dart';
import 'package:ssma/models/purchase.dart';
import 'package:ssma/models/supplier_payment.dart';
import 'package:ssma/utils/sale_metadata.dart';
import 'package:ssma/services/report_models.dart';
import 'package:ssma/services/report_service.dart';

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

                  if (metadata.payments.isNotEmpty) ...[
                    pw.Container(height: 0.5, color: dividerColor),
                    ...metadata.payments.map(
                      (payment) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('${payment.method} Paid:', style: labelStyle),
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

                  if (sale.amountReceived > 0) ...[
                    pw.Container(height: 0.5, color: dividerColor),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Paid:', style: labelStyle),
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
  // generateCustomerLedgerPdf (Plain B&W Tally-style Ledger Statement)
  // =========================================================================
  static Future<void> generateCustomerLedgerPdf({required Customer customer}) async {
    if (!generateFiles) return;

    final prefs = await SharedPreferences.getInstance();
    final storeName = prefs.getString('ssma_store_name') ?? 'Surana Electronics';

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

    final partyName = customer.name.isNotEmpty ? customer.name : 'Customer Account';

    // Fetch all related transactions for this party
    final allSales = await DBService.getAllSales();
    final List<CustomerPayment> allPayments =
        await DBService.getCustomerPaymentsByCustomerUuid(customer.uuid);

    // Filter sales for this party (by UUID or name/phone)
    final partySales = allSales.where((s) {
      if (s.customerUuid != null && s.customerUuid!.isNotEmpty) {
        return s.customerUuid == customer.uuid;
      }
      return (s.buyerName?.toLowerCase() == customer.name.toLowerCase()) ||
          (customer.phone != null && customer.phone!.isNotEmpty && s.buyerContact == customer.phone);
    }).toList();

    // Sort chronologically
    partySales.sort((a, b) => a.date.compareTo(b.date));
    allPayments.sort((a, b) => a.date.compareTo(b.date));

    // Combine into timeline
    final events = <dynamic>[...partySales, ...allPayments];
    events.sort((a, b) {
      final dateA = (a is Sale) ? a.date : (a as CustomerPayment).date;
      final dateB = (b is Sale) ? b.date : (b as CustomerPayment).date;
      return dateA.compareTo(dateB);
    });

    final DateTime startDate = events.isNotEmpty
        ? ((events.first is Sale) ? (events.first as Sale).date : (events.first as CustomerPayment).date)
        : DateTime.now();
    final DateTime endDate = events.isNotEmpty
        ? ((events.last is Sale) ? (events.last as Sale).date : (events.last as CustomerPayment).date)
        : DateTime.now();

    final periodStr =
        '${DateFormat('d-MMM-yyyy').format(startDate)} to ${DateFormat('d-MMM-yyyy').format(endDate)}';

    final indianFmt = NumberFormat('#,##,##0.00', 'en_IN');
    String fmt(double val) => indianFmt.format(val);

    // Calculate opening balance prior to startDate
    double openingBalance = 0.0;
    final priorSales = partySales.where((s) => s.date.isBefore(startDate));
    final priorPayments = allPayments.where((p) => p.date.isBefore(startDate));

    for (final s in priorSales) {
      if (s.saleType == SaleType.credit) {
        openingBalance += s.totalAmount;
        openingBalance -= s.amountReceived;
      }
    }
    for (final p in priorPayments) {
      openingBalance -= p.amountReceived;
    }

    final List<_TallyLedgerRow> rows = [];

    // 1. Opening Balance Row
    if (openingBalance != 0 || events.isEmpty) {
      rows.add(_TallyLedgerRow(
        date: '${startDate.day}-${startDate.month}-${startDate.year}',
        prefix: openingBalance >= 0 ? 'To' : 'By',
        particulars: 'Opening Balance',
        vchType: '',
        vchNo: '',
        debit: openingBalance >= 0 ? openingBalance : null,
        credit: openingBalance < 0 ? -openingBalance : null,
        isOpening: true,
      ));
    }

    // 2. Transaction Rows with payment method breakdown (Cash, UPI, etc.)
    for (final event in events) {
      final dateStr = '${event.date.day}-${event.date.month}-${event.date.year}';

      if (event is Sale) {
        final vchNoStr = event.isarId.toString().padLeft(3, '0');

        // Sales Debit Entry
        rows.add(_TallyLedgerRow(
          date: dateStr,
          prefix: 'To',
          particulars: 'Sales',
          vchType: 'Sales',
          vchNo: vchNoStr,
          debit: event.totalAmount,
          credit: null,
        ));

        // Payment / Receipt Entries (Cash, UPI, etc. breakdown)
        final metadata = SaleMetadata.parse(event.comment);
        if (metadata.payments.isNotEmpty) {
          for (final p in metadata.payments) {
            rows.add(_TallyLedgerRow(
              date: dateStr,
              prefix: 'By',
              particulars: p.method, // e.g. Cash, UPI, Card, Bank Transfer
              vchType: 'Receipt',
              vchNo: vchNoStr,
              debit: null,
              credit: p.amount,
            ));
          }
        } else if (event.amountReceived > 0) {
          rows.add(_TallyLedgerRow(
            date: dateStr,
            prefix: 'By',
            particulars: event.saleType == SaleType.cash ? 'Cash' : 'Receipt',
            vchType: 'Receipt',
            vchNo: vchNoStr,
            debit: null,
            credit: event.amountReceived,
          ));
        }
      } else if (event is CustomerPayment) {
        final vchNoStr = event.isarId.toString().padLeft(3, '0');

        rows.add(_TallyLedgerRow(
          date: dateStr,
          prefix: 'By',
          particulars: 'Cash',
          vchType: 'Receipt',
          vchNo: vchNoStr,
          debit: null,
          credit: event.amountReceived,
        ));
      }
    }

    // Calculate totals
    double totalDebit = 0.0;
    double totalCredit = 0.0;

    for (final r in rows) {
      if (r.debit != null) totalDebit += r.debit!;
      if (r.credit != null) totalCredit += r.credit!;
    }

    final double closingBalance = totalDebit - totalCredit;
    final double grandTotal = totalDebit > totalCredit ? totalDebit : totalCredit;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        header: (context) => pw.Column(
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(partyName,
                      style: pw.TextStyle(font: boldFont, fontSize: 14)),
                  pw.SizedBox(height: 2),
                  pw.Text(storeName,
                      style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  pw.Text('Ledger Account',
                      style: pw.TextStyle(font: font, fontSize: 10)),
                  pw.Text('Shop No:250, Old L.R Market,',
                      style: pw.TextStyle(font: font, fontSize: 9)),
                  pw.Text('Delhi',
                      style: pw.TextStyle(font: font, fontSize: 9)),
                  pw.SizedBox(height: 4),
                  pw.Text(periodStr,
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ],
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Page ${context.pageNumber}',
                  style: pw.TextStyle(font: font, fontSize: 9)),
            ),
          ],
        ),
        build: (context) {
          final tableRows = <pw.TableRow>[];

          // 1. Table Header Row
          tableRows.add(
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 0.75),
                  bottom: pw.BorderSide(color: PdfColors.black, width: 0.75),
                ),
              ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text('Date',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text('Particulars',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text('Vch Type',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text('Vch No.',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Debit',
                        style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Credit',
                        style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  ),
                ),
              ],
            ),
          );

          // 2. Data Rows
          for (final r in rows) {
            tableRows.add(
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text(r.date,
                        style: pw.TextStyle(font: font, fontSize: 9.5)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 20,
                          child: pw.Text(r.prefix,
                              style: pw.TextStyle(font: font, fontSize: 9.5)),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(r.particulars,
                            style: pw.TextStyle(
                                font: r.isOpening ? boldFont : font,
                                fontSize: 9.5)),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text(r.vchType,
                        style: pw.TextStyle(font: font, fontSize: 9.5)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text(r.vchNo,
                        style: pw.TextStyle(font: font, fontSize: 9.5)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        r.debit != null ? fmt(r.debit!) : '',
                        style: pw.TextStyle(
                            font: r.isOpening ? boldFont : font, fontSize: 9.5),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        r.credit != null ? fmt(r.credit!) : '',
                        style: pw.TextStyle(
                            font: r.isOpening ? boldFont : font, fontSize: 9.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 3. Subtotals Row
          tableRows.add(
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                ),
              ),
              children: [
                pw.SizedBox(),
                pw.SizedBox(),
                pw.SizedBox(),
                pw.SizedBox(),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(fmt(totalDebit),
                        style: pw.TextStyle(font: font, fontSize: 9.5)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(fmt(totalCredit),
                        style: pw.TextStyle(font: font, fontSize: 9.5)),
                  ),
                ),
              ],
            ),
          );

          // 4. Closing Balance Row
          tableRows.add(
            pw.TableRow(
              children: [
                pw.SizedBox(),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 20,
                        child: pw.Text('By',
                            style: pw.TextStyle(font: font, fontSize: 9.5)),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text('Closing Balance',
                          style: pw.TextStyle(font: boldFont, fontSize: 9.5)),
                    ],
                  ),
                ),
                pw.SizedBox(),
                pw.SizedBox(),
                pw.SizedBox(),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      closingBalance >= 0 ? fmt(closingBalance) : '',
                      style: pw.TextStyle(font: boldFont, fontSize: 9.5),
                    ),
                  ),
                ),
              ],
            ),
          );

          // 5. Grand Balanced Total Row (with double bottom line!)
          tableRows.add(
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                  bottom: pw.BorderSide(
                      color: PdfColors.black,
                      width: 1.5,
                      style: pw.BorderStyle.solid),
                ),
              ),
              children: [
                pw.SizedBox(),
                pw.SizedBox(),
                pw.SizedBox(),
                pw.SizedBox(),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(fmt(grandTotal),
                        style: pw.TextStyle(font: boldFont, fontSize: 9.5)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(fmt(grandTotal),
                        style: pw.TextStyle(font: boldFont, fontSize: 9.5)),
                  ),
                ),
              ],
            ),
          );

          return [
            pw.Table(
              columnWidths: const {
                0: pw.FixedColumnWidth(65),
                1: pw.FlexColumnWidth(3),
                2: pw.FixedColumnWidth(65),
                3: pw.FixedColumnWidth(50),
                4: pw.FixedColumnWidth(90),
                5: pw.FixedColumnWidth(90),
              },
              children: tableRows,
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/Ledger_${customer.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    if (openGeneratedFiles) {
      await OpenFilex.open(file.path);
    }
  }

  static Future<void> generateLedgerPdf(Sale sale) async {
    final customer = Customer()
      ..uuid = sale.customerUuid ?? ''
      ..name = sale.buyerName ?? 'Customer Account'
      ..phone = sale.buyerContact;
    await generateCustomerLedgerPdf(customer: customer);
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
  // =========================================================================
  // generateExecutiveReportPdf (Executive Business Intelligence Report)
  // =========================================================================
  static Future<void> generateExecutiveReportPdf(BusinessReportData report) async {
    if (!generateFiles) return;

    final prefs = await SharedPreferences.getInstance();
    final storeName = prefs.getString('ssma_store_name') ?? 'Surana Electronics';

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

    final dateFormatter = DateFormat('dd-MMM-yyyy');
    final currencyFmt = NumberFormat('#,##,##0.00', 'en_IN');
    String fmt(double val) => '₹${currencyFmt.format(val)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(storeName, style: pw.TextStyle(font: boldFont, fontSize: 18)),
                  pw.SizedBox(height: 2),
                  pw.Text('EXECUTIVE BUSINESS PERFORMANCE REPORT',
                      style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.grey700)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Period: ${report.presetLabel}',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.Text(
                      '${dateFormatter.format(report.startDate)} to ${dateFormatter.format(report.endDate)}',
                      style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700)),
                  pw.Text('Generated: ${DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now())}',
                      style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 1, color: PdfColors.grey400),
          pw.SizedBox(height: 8),

          // Executive Summary KPI Matrix
          pw.Text('1. EXECUTIVE FINANCIAL SUMMARY',
              style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.indigo900)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _pdfSummaryCell('Total Sales Turnover', fmt(report.grossSales), boldFont, font),
                  _pdfSummaryCell('Cost of Goods (COGS)', fmt(report.cogs), boldFont, font),
                  _pdfSummaryCell('Gross Profit', fmt(report.grossProfit), boldFont, font),
                  _pdfSummaryCell('Profit Margin', '${report.profitMarginPercentage.toStringAsFixed(1)}%', boldFont, font),
                ],
              ),
              pw.TableRow(
                children: [
                  _pdfSummaryCell('Total Orders', '${report.totalOrders} bills', boldFont, font),
                  _pdfSummaryCell('Avg Order Value (AOV)', fmt(report.averageOrderValue), boldFont, font),
                  _pdfSummaryCell('Items Sold', '${report.totalItemsSold} units', boldFont, font),
                  _pdfSummaryCell('Net Cash Flow', fmt(report.netCashFlow), boldFont, font),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // Working Capital & Liquidity
          pw.Text('2. WORKING CAPITAL & LIQUIDITY',
              style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.indigo900)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _pdfSummaryCell('Total Receivables (Dues)', fmt(report.totalCustomerReceivables), boldFont, font),
                  _pdfSummaryCell('Total Supplier Payables', fmt(report.totalSupplierPayables), boldFont, font),
                  _pdfSummaryCell('Net Working Capital', fmt(report.netWorkingCapitalPosition), boldFont, font),
                  _pdfSummaryCell('Cash Collections', fmt(report.totalCashInflow), boldFont, font),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // Inventory & Godown Valuation
          pw.Text('3. INVENTORY & GODOWN VALUATION',
              style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.indigo900)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _pdfSummaryCell('Shop Stock Valuation (Cost)', fmt(report.shopInventoryValuationAtCost), boldFont, font),
                  _pdfSummaryCell('Shop Retail Value', fmt(report.shopInventoryValuationAtRetail), boldFont, font),
                  _pdfSummaryCell('Potential Profit in Stock', fmt(report.potentialInventoryProfit), boldFont, font),
                  _pdfSummaryCell('Godown Valuation', fmt(report.godownInventoryValuationAtCost), boldFont, font),
                ],
              ),
              pw.TableRow(
                children: [
                  _pdfSummaryCell('Shop Units in Stock', '${report.totalShopStockUnits} units', boldFont, font),
                  _pdfSummaryCell('Godown Units in Stock', '${report.totalGodownStockUnits} units', boldFont, font),
                  _pdfSummaryCell('Low Stock Warnings', '${report.lowStockCount} items', boldFont, font),
                  _pdfSummaryCell('Out of Stock', '${report.outOfStockCount} items', boldFont, font),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // Top Performing Products
          if (report.topProductsByRevenue.isNotEmpty) ...[
            pw.Text('4. TOP PERFORMING PRODUCTS',
                style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.indigo900)),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _pdfThCell('Product Name', boldFont),
                    _pdfThCell('Qty Sold', boldFont, align: pw.TextAlign.right),
                    _pdfThCell('Revenue', boldFont, align: pw.TextAlign.right),
                    _pdfThCell('Profit', boldFont, align: pw.TextAlign.right),
                    _pdfThCell('Margin %', boldFont, align: pw.TextAlign.right),
                    _pdfThCell('Current Stock', boldFont, align: pw.TextAlign.right),
                  ],
                ),
                ...report.topProductsByRevenue.take(10).map(
                      (p) => pw.TableRow(
                        children: [
                          _pdfTdCell(p.productName, font),
                          _pdfTdCell('${p.quantitySold}', font, align: pw.TextAlign.right),
                          _pdfTdCell(fmt(p.revenue), font, align: pw.TextAlign.right),
                          _pdfTdCell(fmt(p.profit), font, align: pw.TextAlign.right),
                          _pdfTdCell('${p.marginPercentage.toStringAsFixed(1)}%', font, align: pw.TextAlign.right),
                          _pdfTdCell('${p.currentStock}', font, align: pw.TextAlign.right),
                        ],
                      ),
                    ),
              ],
            ),
            pw.SizedBox(height: 14),
          ],

          // Payment Methods Mix
          if (report.paymentMethods.isNotEmpty) ...[
            pw.Text('5. PAYMENT METHOD DISTRIBUTION',
                style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.indigo900)),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _pdfThCell('Payment Method', boldFont),
                    _pdfThCell('Collected Amount', boldFont, align: pw.TextAlign.right),
                    _pdfThCell('Share (%)', boldFont, align: pw.TextAlign.right),
                    _pdfThCell('Transactions', boldFont, align: pw.TextAlign.right),
                  ],
                ),
                ...report.paymentMethods.map(
                      (pm) => pw.TableRow(
                        children: [
                          _pdfTdCell(pm.method, font),
                          _pdfTdCell(fmt(pm.amount), font, align: pw.TextAlign.right),
                          _pdfTdCell('${pm.percentage.toStringAsFixed(1)}%', font, align: pw.TextAlign.right),
                          _pdfTdCell('${pm.transactionCount}', font, align: pw.TextAlign.right),
                        ],
                      ),
                    ),
              ],
            ),
            pw.SizedBox(height: 14),
          ],

          // Footer note
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Report generated by SSMA System. Confidential & Proprietary.',
                style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/Business_Report_${report.startDate.millisecondsSinceEpoch}_${report.endDate.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    if (openGeneratedFiles) {
      await OpenFilex.open(file.path);
    }
  }

  static pw.Widget _pdfSummaryCell(String title, String value, pw.Font boldFont, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey700)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _pdfThCell(String text, pw.Font boldFont, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(font: boldFont, fontSize: 8), textAlign: align),
    );
  }

  static pw.Widget _pdfTdCell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 8), textAlign: align),
    );
  }

  static Future<void> generateReportPdf({
    required List<Sale> sales,
    required List<Purchase> purchases,
    required List<SupplierPayment> payments,
    required String groupBy,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final report = await ReportService.generateReport(
      startDate: fromDate,
      endDate: toDate,
      presetLabel: 'Custom Report',
    );
    await generateExecutiveReportPdf(report);
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

class _TallyLedgerRow {
  final String date;
  final String prefix;
  final String particulars;
  final String vchType;
  final String vchNo;
  final double? debit;
  final double? credit;
  final bool isOpening;

  const _TallyLedgerRow({
    required this.date,
    required this.prefix,
    required this.particulars,
    required this.vchType,
    required this.vchNo,
    this.debit,
    this.credit,
    this.isOpening = false,
  });
}
