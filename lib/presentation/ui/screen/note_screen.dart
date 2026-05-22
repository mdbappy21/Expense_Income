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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: const Text('Keep Note'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: 20,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: (){
                //if list then move list screen
                //else if text then move text screen
              },
              child: Card(
                color: Colors.grey.shade200,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: const Text('Helfgsdfrgijijfigiujhgiujgijuuuuuuuuuuuuuuuuuuuulo',overflow: .ellipsis,),),
                      IconButton(
                        onPressed:(){},
                        icon: Icon(Icons.delete,color: Colors.red.shade300,),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
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
        size.height*.685,
        0,
        0,
      ),
      color: Colors.grey.shade200,
      items: [
        const PopupMenuItem(
          value: 'list',
          child: Text('List'),
        ),
        const PopupMenuItem(
          value: 'text',
          child: Text('Text'),
        ),
      ],
    );

    if (selected == 'list') {
      Get.to(()=>NoteAddListScreen());
    } else if (selected == 'text') {
      Get.to(()=>NoteAddTextScreen());
    }
  }
}
