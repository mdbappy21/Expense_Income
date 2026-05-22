import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/ui/screen/note_add_list_screen.dart';
import 'package:expense_income/presentation/ui/screen/note_add_text_screen.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  Future<List<Map<String, dynamic>>> _notesFuture = DatabaseHelper.instance.getNotes();

  void _refreshNotes() {
    setState(() {
      _notesFuture = DatabaseHelper.instance.getNotes();
    });
  }

  Future<void> _deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: const Text('Keep Note'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _notesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final notes = snapshot.data ?? [];

            if (notes.isEmpty) {
              return const Center(child: Text('No notes found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return GestureDetector(
                  onTap: () {
                    if (note['type'] == 'list') {
                      Get.to(() => const NoteAddListScreen());
                    } else {
                      Get.to(() => const NoteAddTextScreen());
                    }
                  },
                  child: Card(
                    color: Colors.grey.shade200,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              note['title'] ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteNote(note['id']),
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          _onTapFAB(context);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  void _onTapFAB(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        size.width,
        size.height * .685,
        0,
        0,
      ),
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
      await Get.to(() => const NoteAddListScreen());
      _refreshNotes();
    } else if (selected == 'text') {
      await Get.to(() => const NoteAddTextScreen());
      _refreshNotes();
    }
  }
}