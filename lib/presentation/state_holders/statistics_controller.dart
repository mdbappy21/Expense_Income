import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/state_holders/statistics_pdf_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class StatisticsController extends GetxController {
  String selectedPeriod = 'Day';
  String selectedType = 'Expense';

  bool isLoading = false;

  List<Map<String, dynamic>> transactions = [];
  List<FlSpot> chartSpots = [];

  final List<String> periods = ['Day', 'Week', 'Month', 'Year'];
  final List<String> types = ['Expense', 'Income', 'Borrow'];

  String get title {
    if (selectedType == 'Expense') return 'Top Spending';
    if (selectedType == 'Income') return 'Top Income';
    return 'Top Borrow';
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

      transactions = await DatabaseHelper.instance.getTransactionsByTypeAndPeriod(
        type: selectedType,
        period: selectedPeriod,
      );

      _generateChartSpots();
    } catch (e) {
      print('Statistics load error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  void _generateChartSpots() {
    if (transactions.isEmpty) {
      chartSpots = [const FlSpot(0, 0)];
      return;
    }

    chartSpots = [];

    for (int i = 0; i < transactions.length; i++) {
      final amount = (transactions[i]['amount'] as num).toDouble();
      chartSpots.add(FlSpot(i.toDouble(), amount));
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