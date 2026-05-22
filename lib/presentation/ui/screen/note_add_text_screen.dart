import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';

class NoteAddTextScreen extends StatefulWidget {
  const NoteAddTextScreen({super.key});

  @override
  State<NoteAddTextScreen> createState() => _NoteAddTextScreenState();
}

class _NoteAddTextScreenState extends State<NoteAddTextScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        centerTitle: true,
        title: Text('Add Text'),
        actions: [
          IconButton(onPressed: (){}, icon:Icon(Icons.save)),
          const SizedBox(width: 8)
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Title',
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  maxLines:100,
                  decoration: InputDecoration(
                    hintText: 'Note',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
