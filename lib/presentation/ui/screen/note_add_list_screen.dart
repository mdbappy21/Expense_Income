import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';

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

  void _addItem() {
    setState(() {
      _items.add(TextEditingController());
      _checked.add(false);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
      _checked.removeAt(index);
    });
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
        backgroundColor:AppColors.themeColor,
        title: const Text("Add List"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){}, icon:Icon(Icons.save))
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
            icon: const Icon(
              Icons.close,
            ),
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
        padding: EdgeInsets.all(8),
        child: Row(
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