import 'dart:io';

import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/state_holders/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  bool notificationsEnabled = true;
  bool payableEnabled = true;
  bool receivableEnabled = true;
  int notifyBeforeDays = 1;
  int pendingCount = 0;

  bool notificationPermissionGranted = false;
  bool exactAlarmPermissionGranted = false;
  bool isCheckingPermissions = false;

  List<Map<String, dynamic>> notifications = [];

  late Future<void> _settingsReady;

  @override
  void onInit() {
    super.onInit();
    _settingsReady = _loadSettings();
    _settingsReady.then((_) => rescheduleAllReminders());
    loadPendingCount();
    refreshPermissionStatus();
  }

  Future<void> ensureReady() => _settingsReady;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    payableEnabled = prefs.getBool('payable_notifications') ?? true;
    receivableEnabled = prefs.getBool('receivable_notifications') ?? true;
    notifyBeforeDays = prefs.getInt('notify_before_days') ?? 1;

    update();
  }

  /// Refresh these values whenever the settings screen becomes visible again.
  Future<void> refreshPermissionStatus() async {
    if (isCheckingPermissions) return;

    isCheckingPermissions = true;
    update();

    try {
      if (!Platform.isAndroid) {
        notificationPermissionGranted = true;
        exactAlarmPermissionGranted = true;
      } else {
        await NotificationService.refreshExactAlarmCapability();
        notificationPermissionGranted =
        await NotificationService.areNotificationsEnabled();
        exactAlarmPermissionGranted =
        await NotificationService.canScheduleExactAlarms();
      }
    } catch (error) {
      debugPrint('Permission status check failed: $error');
    } finally {
      isCheckingPermissions = false;
      update();
    }
  }

  Future<void> requestNotificationPermission() async {
    await NotificationService.requestNotificationPermission();
    await refreshPermissionStatus();
    if (notificationPermissionGranted) {
      await rescheduleAllReminders();
    }
  }

  Future<void> requestExactAlarmPermission() async {
    await NotificationService.requestExactAlarmPermission();
    await refreshPermissionStatus();
    await rescheduleAllReminders();
  }

  Future<void> openNotificationSettings() async {
    await NotificationService.openNotificationSettings();
  }

  Future<void> openExactAlarmSettings() async {
    await NotificationService.openExactAlarmSettings();
  }

  Future<void> loadSettings() async {
    _settingsReady = _loadSettings();
    await _settingsReady;
    await rescheduleAllReminders();
    await refreshPermissionStatus();
  }

  /// Badge count represents unread in-app notifications, not open debts.
  Future<void> loadPendingCount() async {
    pendingCount = await DatabaseHelper.instance.getUnreadNotificationsCount();
    update();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await ensureReady();

    if (value) {
      final permissionGranted = await NotificationService.requestPermissions();
      await refreshPermissionStatus();
      if (!permissionGranted || !notificationPermissionGranted) {
        Get.snackbar(
          'Permission required',
          'Allow notifications in Android settings to receive reminders.',
        );
      }
    }

    notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    await rescheduleAllReminders();
    update();
  }

  Future<void> setPayableEnabled(bool value) async {
    await ensureReady();

    if (value && notificationsEnabled) {
      await NotificationService.requestNotificationPermission();
      await refreshPermissionStatus();
    }

    payableEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payable_notifications', value);

    await rescheduleAllReminders();
    update();
  }

  Future<void> setReceivableEnabled(bool value) async {
    await ensureReady();

    if (value && notificationsEnabled) {
      await NotificationService.requestNotificationPermission();
      await refreshPermissionStatus();
    }

    receivableEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('receivable_notifications', value);

    await rescheduleAllReminders();
    update();
  }

  Future<void> setNotifyBeforeDays(int value) async {
    if (![0, 1, 3, 7].contains(value)) return;

    await ensureReady();
    notifyBeforeDays = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notify_before_days', value);

    await rescheduleAllReminders();
    update();
  }

  Future<void> schedulePayableReminder({
    required int payableId,
    required String name,
    required double amount,
    required DateTime dueDate,
  }) async {
    await ensureReady();
    if (!notificationsEnabled || !payableEnabled) return;

    final permissionGranted = await NotificationService.requestPermissions();
    if (!permissionGranted) return;

    await NotificationService.schedulePayableReminder(
      id: NotificationService.payableNotificationId(payableId),
      name: name,
      amount: amount,
      dueDate: dueDate,
      notifyBeforeDays: notifyBeforeDays,
    );
  }

  Future<void> scheduleReceivableReminder({
    required int receivableId,
    required String source,
    required double amount,
    required DateTime expectedDate,
  }) async {
    await ensureReady();
    if (!notificationsEnabled || !receivableEnabled) return;

    final permissionGranted = await NotificationService.requestPermissions();
    if (!permissionGranted) return;

    await NotificationService.scheduleReceivableReminder(
      id: NotificationService.receivableNotificationId(receivableId),
      source: source,
      amount: amount,
      expectedDate: expectedDate,
      notifyBeforeDays: notifyBeforeDays,
    );
  }

  /// Rebuilds reminders using the latest outstanding balance and due date.
  Future<void> rescheduleAllReminders() async {
    await ensureReady();
    await NotificationService.refreshExactAlarmCapability();

    final db = DatabaseHelper.instance;
    final payables = await db.getPayables();
    final receivables = await db.getReceivables();

    for (final payable in payables) {
      final id = (payable['id'] as num).toInt();
      await NotificationService.cancelPayableReminder(id);
    }

    for (final receivable in receivables) {
      final id = (receivable['id'] as num).toInt();
      await NotificationService.cancelReceivableReminder(id);
    }

    if (!notificationsEnabled) return;

    for (final payable in payables) {
      if (payableEnabled && payable['is_returned'] == 0) {
        final returnDate = payable['return_date']?.toString();
        if (returnDate == null || returnDate.isEmpty) continue;

        final id = (payable['id'] as num).toInt();
        final remaining = await db.getPayableRemainingBalance(id);
        if (remaining <= 0.000001) continue;

        await NotificationService.schedulePayableReminder(
          id: NotificationService.payableNotificationId(id),
          name: payable['name'].toString(),
          amount: remaining,
          dueDate: DateTime.parse(returnDate),
          notifyBeforeDays: notifyBeforeDays,
        );
      }
    }

    for (final receivable in receivables) {
      if (receivableEnabled && receivable['is_received'] == 0) {
        final expectedDate = receivable['expected_date']?.toString();
        if (expectedDate == null || expectedDate.isEmpty) continue;

        final id = (receivable['id'] as num).toInt();
        final remaining = await db.getReceivableRemainingBalance(id);
        if (remaining <= 0.000001) continue;

        await NotificationService.scheduleReceivableReminder(
          id: NotificationService.receivableNotificationId(id),
          source: receivable['source'].toString(),
          amount: remaining,
          expectedDate: DateTime.parse(expectedDate),
          notifyBeforeDays: notifyBeforeDays,
        );
      }
    }
  }

  Future<void> cancelPayableReminder(int payableId) async {
    await NotificationService.cancelPayableReminder(payableId);
  }

  Future<void> cancelReceivableReminder(int receivableId) async {
    await NotificationService.cancelReceivableReminder(receivableId);
  }

  Future<void> loadNotifications() async {
    notifications = await DatabaseHelper.instance.getNotifications();
    pendingCount = await DatabaseHelper.instance.getUnreadNotificationsCount();
    update();
  }

  Future<void> markNotificationRead(int id) async {
    await DatabaseHelper.instance.markNotificationRead(id);
    await loadNotifications();
  }

  Future<void> markNotificationUnread(int id) async {
    await DatabaseHelper.instance.markNotificationUnread(id);
    await loadNotifications();
  }
}
