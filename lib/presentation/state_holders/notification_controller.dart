import 'package:expense_income/data/database_helper.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  bool notificationsEnabled = true;

  bool payableEnabled = true;

  bool receivableEnabled = true;

  int notifyBeforeDays = 1;


  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadPendingCount();
  }

  int pendingCount = 0;

  Future<void> loadPendingCount() async {
    final payable =
    await DatabaseHelper.instance.getPendingPayablesCount();

    final receivable =
    await DatabaseHelper.instance.getPendingReceivablesCount();

    pendingCount = payable + receivable;

    update();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    payableEnabled = prefs.getBool('payable_notifications') ?? true;

    receivableEnabled = prefs.getBool('receivable_notifications') ?? true;

    notifyBeforeDays = prefs.getInt('notify_before_days') ?? 1;

    update();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notifications_enabled', value);

    update();
  }

  Future<void> setPayableEnabled(bool value) async {
    payableEnabled = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('payable_notifications', value);

    update();
  }

  Future<void> setReceivableEnabled(bool value) async {
    receivableEnabled = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('receivable_notifications', value);

    update();
  }

  Future<void> setNotifyBeforeDays(int value) async {
    notifyBeforeDays = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('notify_before_days', value);

    update();
  }

  List<Map<String, dynamic>> notifications = [];

  Future<void> loadNotifications() async {
    notifications = await DatabaseHelper.instance.getNotifications();
    update();
  }

  Future<void> markNotificationRead(
      int id,
      ) async {
    // await DatabaseHelper.instance
    //     .markNotificationRead(id);

    await loadNotifications();
  }
}
