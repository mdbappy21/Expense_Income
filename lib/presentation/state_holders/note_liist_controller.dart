import 'package:expense_income/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteListController extends GetxController {
  final TextEditingController titleController = TextEditingController();

  final List<TextEditingController> items = [TextEditingController()];

  final List<bool> checked = [false];

  bool isLoading = false;

  Future<void> loadNote(int? noteId) async {
    if (noteId == null) return;

    final note = await DatabaseHelper.instance.getNoteById(noteId);

    final noteItems = await DatabaseHelper.instance.getNoteItems(noteId);

    if (note == null) return;

    titleController.text = note['title'] ?? '';

    items.clear();
    checked.clear();

    for (final item in noteItems) {
      items.add(TextEditingController(text: item['text']));

      checked.add(item['is_checked'] == 1);
    }

    if (items.isEmpty) {
      items.add(TextEditingController());
      checked.add(false);
    }

    update();
  }

  void addItem() {
    items.add(TextEditingController());
    checked.add(false);
    update();
  }

  void removeItem(int index) {
    if (items.length == 1) {
      items[index].clear();
      checked[index] = false;
      update();
      return;
    }

    items[index].dispose();
    items.removeAt(index);
    checked.removeAt(index);

    update();
  }

  void toggleItem(int index, bool value) {
    checked[index] = value;
    update();
  }

  Future<void> saveNote(int? noteId) async {
    final title = titleController.text.trim();

    final data = <Map<String, dynamic>>[];

    for (int i = 0; i < items.length; i++) {
      final text = items[i].text.trim();

      if (text.isNotEmpty) {
        data.add({'text': text, 'is_checked': checked[i]});
      }
    }

    if (title.isEmpty && data.isEmpty) {
      Get.snackbar('Error', 'Please write something');
      return;
    }

    isLoading = true;
    update();

    if (noteId == null) {
      await DatabaseHelper.instance.insertListNote(
        title: title.isEmpty ? 'Untitled' : title,
        items: data,
      );
    } else {
      await DatabaseHelper.instance.updateListNote(
        noteId: noteId,
        title: title.isEmpty ? 'Untitled' : title,
        items: data,
      );
    }

    isLoading = false;
    update();

    Get.back(result: true);
  }

  @override
  void onClose() {
    titleController.dispose();

    for (final item in items) {
      item.dispose();
    }

    super.onClose();
  }
}
