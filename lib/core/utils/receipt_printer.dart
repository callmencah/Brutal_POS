import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/transaction.dart';
import '../constants/app_constants.dart';

class ReceiptPrinter {
  ReceiptPrinter._();

  /// Generates a PDF document for a 58mm thermal receipt.
  static Future<Uint8List> generateReceiptPdf(Transaction transaction) async {
    final settingsRepo = SettingsRepository();
    final storeName = await settingsRepo.getStoreName();
    final storeAddress = await settingsRepo.getStoreAddress();

    final pdf = pw.Document();
    
    // 58mm thermal printer width is approx 48mm printable area.
    // 48mm = 136 points. We use a continuous roll height.
    final pageFormat = PdfPageFormat.roll57;

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Header
              pw.Text(
                storeName,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              if (storeAddress.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  storeAddress,
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Text(
                'Receipt',
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              
              // Transaction Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(AppConstants.formatDateTime(transaction.createdAt), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('ID:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('#${transaction.id.toString().padLeft(4, '0')}', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              // Items
              if (transaction.items != null)
                ...transaction.items!.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.productName, style: const pw.TextStyle(fontSize: 9)),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('${item.quantity} x ${AppConstants.formatCurrency(item.unitPrice)}', style: const pw.TextStyle(fontSize: 8)),
                            pw.Text(AppConstants.formatCurrency(item.subtotal), style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(AppConstants.formatCurrency(transaction.subtotal), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              if (transaction.taxAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tax (${transaction.taxPercent}%):', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(AppConstants.formatCurrency(transaction.taxAmount), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              if (transaction.discountAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('-${AppConstants.formatCurrency(transaction.discountAmount)}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text(AppConstants.formatCurrency(transaction.total), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              
              // Payment Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Method:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(transaction.paymentMethod.toUpperCase(), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              if (transaction.amountPaid != null)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Paid:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(AppConstants.formatCurrency(transaction.amountPaid!), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              if (transaction.changeAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Change:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(AppConstants.formatCurrency(transaction.changeAmount), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              
              pw.SizedBox(height: 12),
              pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Prints the receipt directly.
  static Future<void> printReceipt(Transaction transaction) async {
    final pdfBytes = await generateReceiptPdf(transaction);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Receipt_${transaction.id.toString().padLeft(4, '0')}',
    );
  }
}
