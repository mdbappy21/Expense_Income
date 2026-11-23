
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
        final colors = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.themeColor,
            foregroundColor: Colors.white,
            title: const Text('Notifications'),
            centerTitle: true,
          ),
          body: controller.notifications.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 80,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurface,
                  ),
                ),
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

                final id = (item['id'] as num).toInt();
                final isRead = item['is_read'] == 1;
                final isPayable = item['type'] == 'payable';

                final createdAt = DateTime.parse(
                  item['created_at'].toString(),
                );

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: colors.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isPayable
                                  ? Colors.red
                                  : Colors.green,
                              child: Icon(
                                isPayable
                                    ? Icons.account_balance_wallet_outlined
                                    : Icons.payments_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['title'].toString(),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: AppColors.themeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['body'].toString(),
                          style: TextStyle(
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat(
                            'dd MMM yyyy • hh:mm a',
                          ).format(createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              if (isRead) {
                                controller.markNotificationUnread(id);
                              } else {
                                controller.markNotificationRead(id);
                              }
                            },
                            icon: Icon(
                              isRead
                                  ? Icons.mark_email_unread_outlined
                                  : Icons.mark_email_read_outlined,
                            ),
                            label: Text(
                              isRead
                                  ? 'Mark as Unread'
                                  : 'Mark as Read',
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
