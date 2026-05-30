import 'package:expense_income/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExpenseController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime? selectedDate;

  final TextEditingController nameTEController = TextEditingController();

  final TextEditingController amountTEController = TextEditingController();

  final TextEditingController descriptionTEController = TextEditingController();

  bool isLoading = false;

  @override
  void onClose() {
    nameTEController.dispose();
    amountTEController.dispose();
    descriptionTEController.dispose();
    super.onClose();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      currentDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select expense date',
      confirmText: 'Select',
      cancelText: 'Cancel',
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      update();
    }
  }

  Future<void> saveExpense() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      Get.snackbar('Error', 'Please select a date');
      return;
    }

    try {
      isLoading = true;
      update();

      await DatabaseHelper.instance.insertExpense(
        name: nameTEController.text.trim(),
        amount: double.parse(amountTEController.text.trim()),
        date: selectedDate!,
        description: descriptionTEController.text.trim(),
      );

      Get.back(result: true);

      Get.snackbar('Success', 'Expense added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }
}
