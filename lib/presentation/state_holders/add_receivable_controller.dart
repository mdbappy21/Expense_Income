import 'package:expense_income/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddReceivableController extends GetxController {
  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>();

  DateTime? expectedDate;

  final TextEditingController sourceTEController =
  TextEditingController();

  final TextEditingController amountTEController =
  TextEditingController();

  final TextEditingController descriptionTEController =
  TextEditingController();

  bool isLoading = false;

  @override
  void onClose() {
    sourceTEController.dispose();
    amountTEController.dispose();
    descriptionTEController.dispose();
    super.onClose();
  }

  Future<void> pickExpectedDate(
      BuildContext context,
      ) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate =
    await showDatePicker(
      context: context,
      initialDate: expectedDate ?? now,
      currentDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      helpText: 'Select expected receive date',
    );

    if (pickedDate != null) {
      expectedDate = pickedDate;
      update();
    }
  }

  Future<void> saveReceivable() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (expectedDate == null) {
      Get.snackbar(
        'Error',
        'Please select expected receive date',
      );
      return;
    }

    try {
      isLoading = true;
      update();

      final receivableId = await DatabaseHelper.instance.insertReceivable(
        source: sourceTEController.text.trim(),
        amount: double.parse(amountTEController.text.trim(),),
        expectedDate: expectedDate!,
        description: descriptionTEController.text.trim(),
      );

      await DatabaseHelper.instance.insertNotification(
        referenceId: receivableId,
        title: 'Collection Reminder',
        body:
        'Receive ${amountTEController.text} TK from ${sourceTEController.text}',
        type: 'receivable',
      );

      isLoading = false;
      update();

      await Future.delayed(
        const Duration(milliseconds: 200),
      );

      Get.back(result: true);

      Get.snackbar(
        'Success',
        'Receivable added successfully',
      );
    } catch (e) {
      isLoading = false;
      update();

      Get.snackbar(
        'Error',
        e.toString(),
      );
    }
  }
}