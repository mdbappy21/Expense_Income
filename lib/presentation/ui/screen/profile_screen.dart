import 'package:expense_income/presentation/state_holders/profile_controller.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildTop(size),
                _buildProfileCard(size),
              ],
            ),

            SizedBox(height: size.height * .14),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTile(
                    icon: Icons.person_outline,
                    title: 'Edit Name',
                    onTap: () {
                      Get.find<ProfileController>().updateName();
                    },
                  ),

                  _buildTile(
                    icon: Icons.photo_camera_outlined,
                    title: 'Change Profile Picture',
                    onTap: () {
                      Get.find<ProfileController>().pickProfileImage();
                    },
                  ),

                  _buildTile(
                    icon: Icons.share_outlined,
                    title: 'Invite Friend',
                    onTap: () {
                      Get.find<ProfileController>().inviteFriend();
                    },
                  ),

                  const Divider(),

                  _buildTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    trailing: const Text('Soon'),
                    onTap: () {},
                  ),

                  _buildTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Theme',
                    trailing: const Text('Soon'),
                    onTap: () {},
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
                        color: Colors.grey.shade600,
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
      ),
    );
  }

  Widget _buildTop(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * .25,
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

  Widget _buildProfileCard(Size size) {
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
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.themeColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
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
            style: TextStyle(color: Colors.grey.shade600),
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expense & Income Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet),
      children: const [
        Text(
          'Track income, expenses, payable and receivable money with detailed statistics and reports.',
        ),
      ],
    );
  }
}
