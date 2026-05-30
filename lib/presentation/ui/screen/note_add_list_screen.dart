import 'package:expense_income/presentation/state_holders/note_liist_controller.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteAddListScreen extends StatelessWidget {
  final int? noteId;

  const NoteAddListScreen({
    super.key,
    this.noteId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NoteListController>(
      initState: (_) {
        Get.find<NoteListController>().loadNote(noteId);
      },
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.themeColor,
            title: Text(
              noteId == null
                  ? 'Add List'
                  : 'Edit List',
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: controller.isLoading
                    ? null
                    : () => controller.saveNote(noteId),
                icon: controller.isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: controller.titleController,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
                        return _buildListItem(
                          controller,
                          index,
                        );
                      },
                    ),
                  ),

                  _buildAddItemButton(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem(
      NoteListController controller,
      int index,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Checkbox(
            value: controller.checked[index],
            activeColor: Colors.grey,
            checkColor: Colors.black,
            side: const BorderSide(
              color: Colors.black,
            ),
            onChanged: (value) {
              controller.toggleItem(
                index,
                value ?? false,
              );
            },
          ),

          Expanded(
            child: TextField(
              controller: controller.items[index],
              style: TextStyle(
                decoration:
                controller.checked[index]
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
              decoration: const InputDecoration(
                hintText: 'List item',
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              controller.removeItem(index);
            },
            icon: const Icon(
              Icons.close,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton(
      NoteListController controller,
      ) {
    return InkWell(
      onTap: controller.addItem,
      child: Container(
        color: Colors.grey,
        padding: const EdgeInsets.all(8),
        child: const Row(
          children: [
            SizedBox(width: 12),
            Icon(Icons.add),
            SizedBox(width: 20),
            Text(
              'List item',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}