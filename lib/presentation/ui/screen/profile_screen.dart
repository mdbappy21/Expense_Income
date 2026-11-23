import 'package:expense_income/presentation/state_holders/notification_controller.dart';
import 'package:expense_income/presentation/state_holders/profile_controller.dart';
import 'package:expense_income/presentation/state_holders/theme_controller.dart';
import 'package:expense_income/presentation/ui/screen/notification_list_screen.dart';
import 'package:expense_income/presentation/ui/screen/notification_screen.dart';
import 'package:expense_income/presentation/ui/screen/payment_management_screen.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [_buildTop(size), _buildProfileCard(size, context)],
          ),
          SizedBox(height: size.height * .14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTile(
                  icon: Icons.person_outline,
                  title: 'Edit Name',
                  onTap: profileController.updateName,
                ),
                _buildTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Change Profile Picture',
                  onTap: profileController.pickProfileImage,
                ),
                _buildTile(
                  icon: Icons.share_outlined,
                  title: 'Invite Friend',
                  onTap: profileController.inviteFriend,
                ),
                const Divider(),
                _buildTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Payment Management',
                  onTap: () {
                    Get.to(() => const PaymentManagementScreen());
                  },
                ),
                _buildTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  trailing: GetBuilder<NotificationController>(
                      builder: (controller) {
                        return CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Text(
                            controller.pendingCount > 99 ? '99+' : controller.pendingCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                  ),
                  onTap: () {
                    Get.to(() => const NotificationListScreen());
                  },
                ),
                _buildTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notification Settings',
                  onTap: () {
                    Get.to(() => const NotificationScreen());
                  },
                ),
                _buildTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Theme',
                  trailing: GetBuilder<ThemeController>(
                    builder: (controller) {
                      return Text(
                        controller.themeModeLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                  onTap: () => _showThemeDialog(),
                ),
                const Divider(),
                _buildTile(
                  icon: Icons.info_outline,
                  title: 'About App',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * .28,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 90),
      decoration: const BoxDecoration(
        color: AppColors.themeColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(300, 70),
          bottomRight: Radius.elliptical(300, 70),
        ),
      ),
      child: const Center(
        child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Size size, BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      top: size.height * .16,
      child: Column(
        children: [
          Stack(
            children: [
              GetBuilder<ProfileController>(
                builder: (controller) {
                  return CircleAvatar(
                    radius: 72,
                    backgroundImage: controller.profileImage,
                  );
                },
              ),
              Positioned(
                right: 0,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.themeColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: profileController.pickProfileImage,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GetBuilder<ProfileController>(
            builder: (controller) {
              return Text(
                controller.userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Expense & Income Tracker',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: AppColors.themeColor),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showThemeDialog() {
    Get.dialog(
      GetBuilder<ThemeController>(
        builder: (controller) {
          return AlertDialog(
            title: const Text('Choose Theme'),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _themeOption(
                  controller: controller,
                  mode: ThemeMode.light,
                  title: 'Light',
                  icon: Icons.light_mode_outlined,
                ),
                _themeOption(
                  controller: controller,
                  mode: ThemeMode.dark,
                  title: 'Dark',
                  icon: Icons.dark_mode_outlined,
                ),
                _themeOption(
                  controller: controller,
                  mode: ThemeMode.system,
                  title: 'System Default',
                  icon: Icons.settings_brightness_outlined,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _themeOption({
    required ThemeController controller,
    required ThemeMode mode,
    required String title,
    required IconData icon,
  }) {
    final isSelected = controller.themeMode == mode;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.themeColor)
          : null,
      onTap: () async {
        await controller.changeThemeMode(mode);
        Get.back();
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expense & Income Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet),
      children: const [
        Text(
          'Track income, expenses, payable and receivable money '
          'with detailed statistics and reports.',
        ),
      ],
    );
  }
}
