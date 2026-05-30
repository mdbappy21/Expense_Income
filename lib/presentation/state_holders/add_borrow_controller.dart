import 'package:expense_income/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBorrowController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime? borrowDate;
  DateTime? returnDate;

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

  Future<void> pickBorrowDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: borrowDate ?? now,
      currentDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select borrow date',
    );

    if (pickedDate != null) {
      borrowDate = pickedDate;
      update();
    }
  }

  Future<void> pickReturnDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: returnDate ?? now,
      currentDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      helpText: 'Select return date',
    );

    if (pickedDate != null) {
      returnDate = pickedDate;
      update();
    }
  }

  Future<void> saveBorrow() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (borrowDate == null) {
      Get.snackbar('Error', 'Please select borrow date');
      return;
    }

    if (returnDate == null) {
      Get.snackbar('Error', 'Please select return date');
      return;
    }

    try {
      isLoading = true;
      update();

      await DatabaseHelper.instance.insertBorrow(
        name: nameTEController.text.trim(),
        amount: double.parse(amountTEController.text.trim()),
        borrowDate: borrowDate!,
        returnDate: returnDate!,
        description: descriptionTEController.text.trim(),
      );

      Get.back(result: true);

      Get.snackbar('Success', 'Borrow added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }
}
