import 'package:expense_income/presentation/state_holders/add_payable_controller.dart';
import 'package:expense_income/presentation/state_holders/add_expense_controller.dart';
import 'package:expense_income/presentation/state_holders/add_income_controller.dart';
import 'package:expense_income/presentation/state_holders/add_receivable_controller.dart';
import 'package:expense_income/presentation/state_holders/home_controller.dart';
import 'package:expense_income/presentation/state_holders/note_controller.dart';
import 'package:expense_income/presentation/state_holders/note_liist_controller.dart';
import 'package:expense_income/presentation/state_holders/note_text_controller.dart';
import 'package:get/get.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddIncomeController>(() => AddIncomeController(), fenix: true);
    Get.lazyPut<AddExpenseController>(() => AddExpenseController(), fenix: true,);
    Get.lazyPut<AddPayableController>(() => AddPayableController(), fenix: true,);
    Get.lazyPut<AddReceivableController>(() => AddReceivableController(), fenix: true,);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<NoteController>(() => NoteController(), fenix: true);
    Get.lazyPut<NoteTextController>(() => NoteTextController(), fenix: true);
    Get.lazyPut<NoteListController>(() => NoteListController(), fenix: true);
  }
}
