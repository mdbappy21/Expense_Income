import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StatisticsPdfService {
  static Future<void> exportStatisticsPdf({
    required String selectedType,
    required String selectedPeriod,
    required List<Map<String, dynamic>> transactions,
  }) async {
    final pdf = pw.Document();

    final now = DateTime.now();

    final totalAmount = transactions.fold<double>(
      0,
      (sum, item) => sum + ((item['amount'] as num).toDouble()),
    );

    String periodRange = '';

    switch (selectedPeriod) {
      case 'Day':
        periodRange = DateFormat('EEEE, dd MMM yyyy').format(now);
        break;

      case 'Week':
        final start = now.subtract(Duration(days: now.weekday - 1));

        final end = start.add(const Duration(days: 6));

        periodRange =
            '${DateFormat('dd MMM').format(start)} - '
            '${DateFormat('dd MMM yyyy').format(end)}';
        break;

      case 'Month':
        final start = DateTime(now.year, now.month, 1);

        final end = DateTime(now.year, now.month + 1, 0);

        periodRange =
            '${DateFormat('dd MMM').format(start)} - '
            '${DateFormat('dd MMM yyyy').format(end)}';
        break;

      case 'Year':
        periodRange = '${now.year}';
        break;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            /// Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'Expense & Income Manager',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    '$selectedType Report',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(periodRange, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            /// Report Information
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Report Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text('Report Type : $selectedType'),

                  pw.Text('Period : $selectedPeriod'),

                  pw.Text('Range : $periodRange'),

                  pw.Text(
                    'Generated On : '
                    '${DateFormat('dd MMM yyyy, hh:mm a').format(now)}',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            /// Summary
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text('Total Records : ${transactions.length}'),

                  pw.Text(
                    'Total Amount : '
                    '${totalAmount.toStringAsFixed(2)} TK',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            /// Transactions Title
            pw.Text(
              'Transaction Details',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            /// Transaction Table
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headers: const ['SL', 'Title', 'Amount', 'Date', 'Description'],
              data: List.generate(transactions.length, (index) {
                final item = transactions[index];

                final date = DateTime.parse(item['date']);

                return [
                  '${index + 1}',
                  item['title'] ?? '',
                  '${(item['amount'] as num).toStringAsFixed(2)} TK',
                  DateFormat('dd MMM yyyy').format(date),
                  item['description'] ?? '',
                ];
              }),
            ),

            pw.SizedBox(height: 20),

            /// Footer
            pw.Divider(),

            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'Generated by Expense & Income Manager',
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(now),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
