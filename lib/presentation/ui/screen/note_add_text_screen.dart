import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:expense_income/data/database_helper.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NoteAddTextScreen extends StatefulWidget {
  const NoteAddTextScreen({super.key});

  @override
  State<NoteAddTextScreen> createState() => _NoteAddTextScreenState();
}

class _NoteAddTextScreenState extends State<NoteAddTextScreen> {
  final TextEditingController _titleTEController = TextEditingController();
  final TextEditingController _noteTEController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleTEController.dispose();
    _noteTEController.dispose();
    super.dispose();
  }

  Future<void> _saveTextNote() async {
    final title = _titleTEController.text.trim();
    final note = _noteTEController.text.trim();

    if (title.isEmpty && note.isEmpty) {
      Get.snackbar('Error', 'Please write something');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await DatabaseHelper.instance.insertTextNote(
      title: title.isEmpty ? 'Untitled' : title,
      content: note,
    );

    setState(() {
      _isLoading = false;
    });

    Get.snackbar('Success', 'Note saved');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        centerTitle: true,
        title: const Text('Add Text'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveTextNote,
            icon: _isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.save),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleTEController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteTEController,
                  maxLines: 100,
                  decoration: const InputDecoration(
                    hintText: 'Note',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
