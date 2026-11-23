import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/state_holders/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPayableController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime? payableDate;
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

  Future<void> pickPayableDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: payableDate ?? now,
      currentDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select payable date',
    );

    if (pickedDate != null) {
      payableDate = pickedDate;
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

  Future<void> savePayable() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (payableDate == null) {
      Get.snackbar('Error', 'Please select payable date');
      return;
    }

    if (returnDate == null) {
      Get.snackbar('Error', 'Please select return date');
      return;
    }

    try {
      isLoading = true;
      update();

      final payableId = await DatabaseHelper.instance.insertPayable(
        name: nameTEController.text.trim(),
        amount: double.parse(amountTEController.text.trim()),
        payableDate: payableDate!,
        returnDate: returnDate!,
        description: descriptionTEController.text.trim(),
      );

      await DatabaseHelper.instance.insertNotification(
        referenceId: payableId,
        title: 'Payment Reminder',
        body: 'Pay ${amountTEController.text} TK to ${nameTEController.text}',
        type: 'payable',
      );

      // The expected payment/return date is the actual payable due date.
      // Failure to schedule a phone notification must not discard the record.
      try {
        await Get.find<NotificationController>().schedulePayableReminder(
          payableId: payableId,
          name: nameTEController.text.trim(),
          amount: double.parse(amountTEController.text.trim()),
          dueDate: returnDate!,
        );
      } catch (_) {
        Get.snackbar(
          'Reminder not scheduled',
          'The payable was saved, but its phone reminder could not be scheduled.',
        );
      }

      isLoading = false;
      update();

      await Future.delayed(const Duration(milliseconds: 200));

      Get.back(result: true);

      Get.snackbar('Success', 'Payable added successfully');
    } catch (e) {
      isLoading = false;
      update();

      Get.snackbar('Error', e.toString());
    }
  }
}
