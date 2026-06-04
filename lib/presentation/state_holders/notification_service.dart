import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await notifications.initialize(settings: settings);
  }

  static Future<void> schedulePayableReminder({
    required int id,
    required String name,
    required double amount,
    required DateTime dueDate,
  }) async {
    await notifications.zonedSchedule(
      id: id,
      title: 'Payment Reminder',
      body: 'You need to pay $name • ${amount.toStringAsFixed(2)} TK',
      scheduledDate: tz.TZDateTime.from(dueDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'payable_channel',
          'Payable Reminders',
          channelDescription: 'Notifications for payable reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'payable',
    );
  }

  static Future<void> scheduleReceivableReminder({
    required int id,
    required String source,
    required double amount,
    required DateTime expectedDate,
  }) async {
    await notifications.zonedSchedule(
      id: id,
      title: 'Collection Reminder',
      body: 'Receive ${amount.toStringAsFixed(2)} TK from $source',
      scheduledDate: tz.TZDateTime.from(expectedDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'receivable_channel',
          'Receivable Reminders',
          channelDescription: 'Notifications for receivable reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'receivable',
    );
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

  static Future<void> cancelAll() async {
    await notifications.cancelAll();
  }
}
