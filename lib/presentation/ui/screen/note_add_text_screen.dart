import 'package:expense_income/presentation/state_holders/note_text_controller.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteAddTextScreen extends StatelessWidget {
  final int? noteId;

  const NoteAddTextScreen({super.key, this.noteId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NoteTextController>(
      initState: (_) {
        Get.find<NoteTextController>().loadNote(noteId);
      },
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.themeColor,
            centerTitle: true,
            title: Text(noteId == null ? 'Add Text' : 'Edit Text'),
            actions: [
              IconButton(
                onPressed: controller.isLoading
                    ? null
                    : () => controller.saveNote(noteId),
                icon: controller.isLoading
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
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: controller.titleTEController,
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
                      controller: controller.noteTEController,
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
      },
    );
  }
}
