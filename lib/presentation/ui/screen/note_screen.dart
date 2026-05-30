import 'package:expense_income/presentation/state_holders/note_controller.dart';
import 'package:expense_income/presentation/ui/screen/note_add_list_screen.dart';
import 'package:expense_income/presentation/ui/screen/note_add_text_screen.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: const Text('Keep Note'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GetBuilder<NoteController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.notes.isEmpty) {
              return const Center(
                child: Text('No notes found'),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadNotes,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.notes.length,
                itemBuilder: (context, index) {
                  final note = controller.notes[index];

                  return GestureDetector(
                    onTap: () async {
                      if (note['type'] == 'list') {
                        await Get.to(
                              () => NoteAddListScreen(
                            noteId: note['id'],
                          ),
                        );
                      } else {
                        await Get.to(
                              () => NoteAddTextScreen(
                            noteId: note['id'],
                          ),
                        );
                      }

                      controller.loadNotes();
                    },
                    child: Card(
                      color: Colors.grey.shade200,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                note['title'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await controller.deleteNote(
                                  note['id'],
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'note_fab',
        shape: const CircleBorder(),
        backgroundColor: Colors.teal,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () => _onTapFAB(context),
      ),
    );
  }

  Future<void> _onTapFAB(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(size.width, size.height * .685, 0, 0),
      color: Colors.grey.shade200,
      items: const [
        PopupMenuItem(
          value: 'list',
          child: Text('List'),
        ),
        PopupMenuItem(
          value: 'text',
          child: Text('Text'),
        ),
      ],
    );

    if (selected == 'list') {
      final result = await Get.to(
            () => const NoteAddListScreen(),
      );

      if (result == true) {
        Get.find<NoteController>().loadNotes();
      }
    }

    if (selected == 'text') {
      final result = await Get.to(
            () => const NoteAddTextScreen(),
      );

      if (result == true) {
        Get.find<NoteController>().loadNotes();
      }
    }
  }
}