import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StatisticsPdfService {
  static Future<void> exportStatisticsPdf({
    required String selectedType,
    required String selectedPeriod,
    required List<Map<String, dynamic>> transactions,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Text(
              '$selectedType Report - $selectedPeriod',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Title', 'Amount', 'Date', 'Description'],
              data: transactions.map((item) {
                final date = DateTime.parse(item['date']);

                return [
                  item['title'] ?? '',
                  '${(item['amount'] as num).toStringAsFixed(2)} TK',
                  DateFormat('dd MMM yyyy').format(date),
                  item['description'] ?? '',
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}