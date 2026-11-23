import 'package:expense_income/presentation/state_holders/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshPermissionStatus();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().refreshPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<NotificationController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notification Settings'),
            actions: [
              IconButton(
                tooltip: 'Refresh permission status',
                onPressed: controller.refreshPermissionStatus,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _sectionTitle(context, 'System Permissions'),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _permissionTile(
                      context: context,
                      icon: Icons.notifications_active_outlined,
                      title: 'Notification Permission',
                      subtitle: controller.notificationPermissionGranted
                          ? 'Android allows this app to show notifications.'
                          : 'Required to display reminders and alerts.',
                      granted: controller.notificationPermissionGranted,
                      loading: controller.isCheckingPermissions,
                      actionLabel: controller.notificationPermissionGranted
                          ? 'Refresh'
                          : 'Allow',
                      onAction: controller.notificationPermissionGranted
                          ? controller.refreshPermissionStatus
                          : controller.requestNotificationPermission,
                      onSettings: controller.openNotificationSettings,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _permissionTile(
                      context: context,
                      icon: Icons.alarm_on_outlined,
                      title: 'Alarms & Reminders',
                      subtitle: controller.exactAlarmPermissionGranted
                          ? 'Exact alarm access is allowed.'
                          : 'Allow exact alarms for more precise reminder timing. Inexact reminders may still work.',
                      granted: controller.exactAlarmPermissionGranted,
                      loading: controller.isCheckingPermissions,
                      actionLabel: controller.exactAlarmPermissionGranted
                          ? 'Refresh'
                          : 'Grant Access',
                      onAction: controller.exactAlarmPermissionGranted
                          ? controller.refreshPermissionStatus
                          : controller.requestExactAlarmPermission,
                      onSettings: controller.openExactAlarmSettings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Permission status is read from Android. If you change a permission in system settings, return to this screen and its status will refresh automatically.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Reminder Preferences'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Master switch for app reminders'),
                      value: controller.notificationsEnabled,
                      onChanged: controller.setNotificationsEnabled,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      secondary: const Icon(Icons.payments_outlined),
                      title: const Text('Payable Reminder'),
                      subtitle: const Text('Remind me about money I need to pay'),
                      value: controller.payableEnabled,
                      onChanged: controller.setPayableEnabled,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      secondary: const Icon(Icons.account_balance_wallet_outlined),
                      title: const Text('Receivable Reminder'),
                      subtitle: const Text('Remind me about money I should receive'),
                      value: controller.receivableEnabled,
                      onChanged: controller.setReceivableEnabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Notify Before'),
              Card(
                child: RadioGroup<int>(
                  groupValue: controller.notifyBeforeDays,
                  onChanged: (value) {
                    if (value != null) controller.setNotifyBeforeDays(value);
                  },
                  child: const Column(
                    children: [
                      RadioListTile<int>(
                        title: Text('Same Day'),
                        value: 0,
                      ),
                      RadioListTile<int>(
                        title: Text('1 Day Before'),
                        value: 1,
                      ),
                      RadioListTile<int>(
                        title: Text('3 Days Before'),
                        value: 3,
                      ),
                      RadioListTile<int>(
                        title: Text('7 Days Before'),
                        value: 7,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Daily Reminder Time'),
                  subtitle: const Text('Reminders are scheduled for 06:00 AM'),
                  trailing: const Text('06:00 AM'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _permissionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
    required bool loading,
    required String actionLabel,
    required VoidCallback onAction,
    required VoidCallback onSettings,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  granted ? Icons.check_circle : Icons.error_outline,
                  color: granted ? Colors.green : colors.error,
                ),
              const SizedBox(width: 6),
              Text(
                loading ? 'Checking' : (granted ? 'Allowed' : 'Not allowed'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: loading
                      ? colors.onSurfaceVariant
                      : (granted ? Colors.green : colors.error),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: loading ? null : onSettings,
                child: const Text('Open Settings'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: loading ? null : onAction,
                child: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
