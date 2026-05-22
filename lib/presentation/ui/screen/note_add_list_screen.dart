import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteAddListScreen extends StatefulWidget {
  const NoteAddListScreen({super.key});

  @override
  State<NoteAddListScreen> createState() => _NoteAddListScreenState();
}

class _NoteAddListScreenState extends State<NoteAddListScreen> {
  final TextEditingController _titleController = TextEditingController();

  final List<TextEditingController> _items = [
    TextEditingController(),
  ];

  final List<bool> _checked = [
    false,
  ];

  bool _isLoading = false;

  void _addItem() {
    setState(() {
      _items.add(TextEditingController());
      _checked.add(false);
    });
  }

  void _removeItem(int index) {
    if (_items.length == 1) {
      _items[index].clear();
      setState(() {
        _checked[index] = false;
      });
      return;
    }

    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
      _checked.removeAt(index);
    });
  }

  Future<void> _saveListNote() async {
    final title = _titleController.text.trim();

    final items = <Map<String, dynamic>>[];

    for (int i = 0; i < _items.length; i++) {
      final text = _items[i].text.trim();

      if (text.isNotEmpty) {
        items.add({
          'text': text,
          'is_checked': _checked[i],
        });
      }
    }

    if (title.isEmpty && items.isEmpty) {
      Get.snackbar('Error', 'Please write something');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await DatabaseHelper.instance.insertListNote(
      title: title.isEmpty ? 'Untitled' : title,
      items: items,
    );

    setState(() {
      _isLoading = false;
    });

    Get.snackbar('Success', 'List note saved');
    Get.back();
  }

  @override
  void dispose() {
    _titleController.dispose();

    for (final controller in _items) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: const Text("Add List"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveListNote,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
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
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildListItem(index);
                  },
                ),
              ),
              _buildAddItemButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: _checked[index],
            activeColor: Colors.grey,
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            onChanged: (value) {
              setState(() {
                _checked[index] = value ?? false;
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _items[index],
              style: TextStyle(
                decoration: _checked[index]
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
              decoration: const InputDecoration(
                hintText: 'List item',
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeItem(index),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return InkWell(
      onTap: _addItem,
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