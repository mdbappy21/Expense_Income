import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/state_holders/home_controller.dart';
import 'package:expense_income/presentation/state_holders/notification_controller.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      initState: (_) {
        Get.find<NotificationController>().loadNotifications();
      },
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.themeColor,
            title: const Text('Notifications'),
            centerTitle: true,
          ),
          body: controller.notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text('No Notifications', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final item = controller.notifications[index];

                      final isRead = item['is_read'] == 1;

                      final createdAt = DateTime.parse(item['created_at']);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                    item['type'] == 'payable'
                                        ? Colors.red
                                        : Colors.green,
                                    child: Icon(
                                      item['type'] == 'payable'
                                          ? Icons.payments_outlined
                                          : Icons.account_balance_wallet_outlined,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(item['body']),

                              const SizedBox(height: 8),

                              Text(
                                DateFormat(
                                  'dd MMM yyyy • hh:mm a',
                                ).format(createdAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (item['type'] == 'payable') {
                                      await DatabaseHelper.instance
                                          .markPayablePaid(
                                        item['reference_id'],
                                      );
                                    } else {
                                      await DatabaseHelper.instance
                                          .markReceivableReceived(
                                        item['reference_id'],
                                      );
                                    }

                                    await controller.loadNotifications();
                                    await controller.loadPendingCount();

                                    Get.find<HomeController>()
                                        .loadHomeData();
                                  },
                                  child: Text(
                                    item['type'] == 'payable'
                                        ? 'Mark Paid'
                                        : 'Mark Received',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
