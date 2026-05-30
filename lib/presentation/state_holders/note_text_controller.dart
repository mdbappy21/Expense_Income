import 'package:expense_income/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteTextController extends GetxController {
  final TextEditingController titleTEController =
  TextEditingController();

  final TextEditingController noteTEController =
  TextEditingController();

  bool isLoading = false;

  Future<void> loadNote(int? noteId) async {
    if (noteId == null) return;

    final note =
    await DatabaseHelper.instance.getNoteById(
      noteId,
    );

    if (note == null) return;

    titleTEController.text =
        note['title'] ?? '';

    noteTEController.text =
        note['content'] ?? '';

    update();
  }

  Future<void> saveNote(int? noteId) async {
    final title =
    titleTEController.text.trim();

    final note =
    noteTEController.text.trim();

    if (title.isEmpty && note.isEmpty) {
      Get.snackbar(
        'Error',
        'Please write something',
      );
      return;
    }

    isLoading = true;
    update();

    if (noteId == null) {
      await DatabaseHelper.instance.insertTextNote(
        title: title.isEmpty
            ? 'Untitled'
            : title,
        content: note,
      );
    } else {
      await DatabaseHelper.instance.updateTextNote(
        id: noteId,
        title: title.isEmpty
            ? 'Untitled'
            : title,
        content: note,
      );
    }

    isLoading = false;
    update();

    Get.back(result: true);
  }

  @override
  void onClose() {
    titleTEController.dispose();
    noteTEController.dispose();
    super.onClose();
  }
}