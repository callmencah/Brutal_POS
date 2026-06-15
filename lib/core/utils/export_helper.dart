import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportHelper {
  ExportHelper._();

  /// Exports data to CSV and shares it
  static Future<void> exportToCsv({
    required String fileName,
    required List<List<dynamic>> rows,
  }) async {
    final csvData = ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.csv');
    await file.writeAsString(csvData);

    final xFile = XFile(file.path, mimeType: 'text/csv');
    await Share.shareXFiles([xFile], text: 'Report: $fileName');
  }

  /// Exports data to Excel and shares it
  static Future<void> exportToExcel({
    required String fileName,
    required List<List<dynamic>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    for (int i = 0; i < rows.length; i++) {
      sheet.appendRow(rows[i].map((e) => TextCellValue(e.toString())).toList());
    }

    final bytes = excel.encode()!;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.xlsx');
    await file.writeAsBytes(bytes);

    final xFile = XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    await Share.shareXFiles([xFile], text: 'Report: $fileName');
  }

  /// Exports data to PDF and shares it
  static Future<void> exportToPdf({
    required String fileName,
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                for (int i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);

    final xFile = XFile(file.path, mimeType: 'application/pdf');
    await Share.shareXFiles([xFile], text: 'Report: $fileName');
  }
}
