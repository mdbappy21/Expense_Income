import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  static const MethodChannel _settingsChannel = MethodChannel(
    'com.example.expense_income/notification_settings',
  );

  static AndroidScheduleMode _scheduleMode =
      AndroidScheduleMode.inexactAllowWhileIdle;

  static const int _notificationIdOffset = 1000000;
  static const int reminderHour = 6;
  static const int reminderMinute = 0;

  static int payableNotificationId(int payableId) =>
      _notificationIdOffset + (payableId * 2);

  static int receivableNotificationId(int receivableId) =>
      _notificationIdOffset + (receivableId * 2) + 1;

  static Future<void> initialize() async {
    tzdata.initializeTimeZones();

    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (error) {
      // Keep the timezone package's default location if platform lookup fails.
      // ignore: avoid_print
      print('Could not load device timezone: $error');
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await notifications.initialize(settings: settings);
    await refreshExactAlarmCapability();
  }

  /// True when Android currently allows this app to post notifications.
  static Future<bool> areNotificationsEnabled() async {
    if (!Platform.isAndroid) return true;

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;

    return await android.areNotificationsEnabled() ?? false;
  }

  /// True when Android currently allows exact scheduled alarms.
  static Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;

    return await android.canScheduleExactNotifications() ?? false;
  }

  /// Requests only the Android notification runtime permission.
  static Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;

    await android.requestNotificationsPermission();
    return areNotificationsEnabled();
  }

  /// Opens Android's special Alarms & reminders access screen.
  static Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    if (!await canScheduleExactAlarms()) {
      await android.requestExactAlarmsPermission();
    }
    await refreshExactAlarmCapability();
  }

  static Future<void> openNotificationSettings() async {
    if (!Platform.isAndroid) return;
    await _settingsChannel.invokeMethod<void>('openNotificationSettings');
  }

  static Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    await _settingsChannel.invokeMethod<void>('openExactAlarmSettings');
  }

  /// Keeps the existing combined permission request API for compatibility.
  /// Exact alarms are requested only once automatically; users can request
  /// them again explicitly from Notification Settings.
  static Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    final notificationGranted = await requestNotificationPermission();
    if (!notificationGranted) return false;

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) await _requestExactAlarmPermissionOnce(android);
    return true;
  }

  static Future<void> refreshExactAlarmCapability() async {
    final granted = await canScheduleExactAlarms();
    _scheduleMode = granted
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static Future<void> _requestExactAlarmPermissionOnce(
      AndroidFlutterLocalNotificationsPlugin android,
      ) async {
    if (await android.canScheduleExactNotifications() == true) {
      _scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool('exact_alarm_permission_asked') ?? false;

    if (!alreadyAsked) {
      await prefs.setBool('exact_alarm_permission_asked', true);
      await android.requestExactAlarmsPermission();
    }
    await refreshExactAlarmCapability();
  }

  static tz.TZDateTime reminderDateTime({
    required DateTime dueDate,
    required int notifyBeforeDays,
  }) {
    final reminderDate = DateTime(dueDate.year, dueDate.month, dueDate.day)
        .subtract(Duration(days: notifyBeforeDays));

    return tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      reminderHour,
      reminderMinute,
    );
  }

  static Future<bool> schedulePayableReminder({
    required int id,
    required String name,
    required double amount,
    required DateTime dueDate,
    required int notifyBeforeDays,
  }) async {
    final scheduledDate = reminderDateTime(
      dueDate: dueDate,
      notifyBeforeDays: notifyBeforeDays,
    );

    await cancelNotification(id);
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) return false;

    await notifications.zonedSchedule(
      id: id,
      title: 'Payment Reminder',
      body: 'You need to pay $name • ${amount.toStringAsFixed(2)} TK',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'payable_channel',
          'Payable Reminders',
          channelDescription: 'Notifications for payable reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: _scheduleMode,
      payload: 'payable',
    );

    return true;
  }

  static Future<bool> scheduleReceivableReminder({
    required int id,
    required String source,
    required double amount,
    required DateTime expectedDate,
    required int notifyBeforeDays,
  }) async {
    final scheduledDate = reminderDateTime(
      dueDate: expectedDate,
      notifyBeforeDays: notifyBeforeDays,
    );

    await cancelNotification(id);
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) return false;

    await notifications.zonedSchedule(
      id: id,
      title: 'Collection Reminder',
      body: 'Receive ${amount.toStringAsFixed(2)} TK from $source',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'receivable_channel',
          'Receivable Reminders',
          channelDescription: 'Notifications for receivable reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: _scheduleMode,
      payload: 'receivable',
    );

    return true;
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          channelDescription: 'General application notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await notifications.cancel(id: id);
  }

  static Future<void> cancelPayableReminder(int payableId) async {
    await cancelNotification(payableNotificationId(payableId));
  }

  static Future<void> cancelReceivableReminder(int receivableId) async {
    await cancelNotification(receivableNotificationId(receivableId));
  }

  static Future<void> cancelAll() async {
    await notifications.cancelAll();
  }
}
