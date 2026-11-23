import 'package:expense_income/data/database_helper.dart';
import 'package:get/get.dart';

class NoteController extends GetxController {
  bool isLoading = true;

  List<Map<String, dynamic>> notes = [];

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      isLoading = true;
      update();

      notes = await DatabaseHelper.instance.getNotes();
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    await loadNotes();
  }
}
