import 'package:expense_income/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddIncomeController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime? selectedDate;

  final TextEditingController categoryTEController = TextEditingController();

  final TextEditingController amountTEController = TextEditingController();

  final TextEditingController descriptionTEController = TextEditingController();

  bool isLoading = false;

  @override
  void onClose() {
    categoryTEController.dispose();
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
      helpText: 'Select income date',
      confirmText: 'Select',
      cancelText: 'Cancel',
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      update();
    }
  }

  Future<void> saveIncome() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      Get.snackbar(
        'Error',
        'Please select a date',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading = true;
      update();

      await DatabaseHelper.instance.insertIncome(
        category: categoryTEController.text.trim(),
        amount: double.parse(amountTEController.text.trim()),
        date: selectedDate!,
        description: descriptionTEController.text.trim(),
      );

      isLoading = false;
      update();
      await Future.delayed(const Duration(milliseconds: 200));
      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Income added successfully',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isLoading = false;
      update();

      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
