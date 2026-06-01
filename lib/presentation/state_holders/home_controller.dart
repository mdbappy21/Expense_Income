import 'package:expense_income/data/database_helper.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  bool isLoading = true;

  double income = 0;
  double expense = 0;
  double payable = 0;
  double receivable = 0;
  double balance = 0;

  List<Map<String, dynamic>> transactions = [];

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading = true;
      update();

      income = await DatabaseHelper.instance.getIncomeTotal();

      expense = await DatabaseHelper.instance.getExpenseTotal();

      payable = await DatabaseHelper.instance.getPayableTotal();

      receivable = await DatabaseHelper.instance.getReceivableTotal();

      transactions =
      await DatabaseHelper.instance.getAllTransactions();

      balance = income + receivable - expense - payable;
    } finally {
      isLoading = false;
      update();
    }
  }

  String get welcomeMessage {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning,';
    } else if (hour >= 12 && hour < 14) {
      return 'Good noon,';
    } else if (hour >= 14 && hour < 17) {
      return 'Good afternoon,';
    } else if (hour >= 17 && hour < 20) {
      return 'Good evening,';
    } else {
      return 'Good night,';
    }
  }
}