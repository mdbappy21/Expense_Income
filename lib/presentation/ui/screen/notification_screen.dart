import 'package:expense_income/presentation/state_holders/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Notification Settings')),
          body: ListView(
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: controller.notificationsEnabled,
                onChanged: controller.setNotificationsEnabled,
              ),

              const Divider(),

              SwitchListTile(
                title: const Text('Payable Reminder'),
                value: controller.payableEnabled,
                onChanged: controller.setPayableEnabled,
              ),

              SwitchListTile(
                title: const Text('Receivable Reminder'),
                value: controller.receivableEnabled,
                onChanged: controller.setReceivableEnabled,
              ),

              const Divider(),

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Notify Before',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              RadioListTile<int>(
                title: const Text('Same Day'),
                value: 0,
                groupValue: controller.notifyBeforeDays,
                onChanged: (value) {
                  controller.setNotifyBeforeDays(value!);
                },
              ),

              RadioListTile<int>(
                title: const Text('1 Day Before'),
                value: 1,
                groupValue: controller.notifyBeforeDays,
                onChanged: (value) {
                  controller.setNotifyBeforeDays(value!);
                },
              ),

              RadioListTile<int>(
                title: const Text('3 Days Before'),
                value: 3,
                groupValue: controller.notifyBeforeDays,
                onChanged: (value) {
                  controller.setNotifyBeforeDays(value!);
                },
              ),

              RadioListTile<int>(
                title: const Text('7 Days Before'),
                value: 7,
                groupValue: controller.notifyBeforeDays,
                onChanged: (value) {
                  controller.setNotifyBeforeDays(value!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
