import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/state_holders/statistics_pdf_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StatisticsController extends GetxController {
  String selectedPeriod = 'Day';

  String selectedType = 'Income';

  bool isLoading = false;

  List<Map<String, dynamic>> transactions = [];

  List<FlSpot> chartSpots = [];

  List<String> chartLabels = [];

  final List<String> periods = ['Day', 'Week', 'Month', 'Year'];

  final List<String> types = ['Income', 'Expense', 'Payable', 'Receivable'];

  String get title {
    if (selectedType == 'Income') {
      return 'Top Income';
    }

    if (selectedType == 'Expense') {
      return 'Top Spending';
    }

    if (selectedType == 'Payable') {
      return 'Top Payable';
    }

    return 'Top Receivable';
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> changePeriod(String value) async {
    selectedPeriod = value;
    await loadData();
  }

  Future<void> changeType(String value) async {
    selectedType = value;
    await loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading = true;
      update();

      transactions = await DatabaseHelper.instance
          .getTransactionsByTypeAndPeriod(
            type: selectedType,
            period: selectedPeriod,
          );

      _generateChartSpots();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  void _generateChartSpots() {
    chartSpots = [];

    chartLabels = [];

    for (int i = 0; i < transactions.length; i++) {
      final amount = (transactions[i]['amount'] as num).toDouble();

      final date = DateTime.parse(transactions[i]['date']);

      chartSpots.add(FlSpot(i.toDouble(), amount));

      switch (selectedPeriod) {
        case 'Day':
          chartLabels.add(DateFormat('HH:mm').format(date));
          break;

        case 'Week':
          chartLabels.add(DateFormat('EEE').format(date));
          break;

        case 'Month':
          chartLabels.add(DateFormat('dd\nMMM').format(date));
          break;

        case 'Year':
          chartLabels.add(DateFormat('MMM').format(date));
          break;
      }
    }
  }

  Future<void> exportPdf() async {
    await StatisticsPdfService.exportStatisticsPdf(
      selectedType: selectedType,
      selectedPeriod: selectedPeriod,
      transactions: transactions,
    );
  }
}