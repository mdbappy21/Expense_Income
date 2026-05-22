import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child:Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildTop(size),
                _buildProfile(size),
              ],
            ),
            SizedBox(height: size.height*.12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Invite Friend'),
                    leading: Icon(Icons.diamond,color: AppColors.themeColor,),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Edit Profile'),
                    leading: Icon(Icons.edit,color: AppColors.themeColor,),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text('Buy me a coffee'),
                    leading: Icon(Icons.coffee,color: AppColors.themeColor,),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text('Logout'),
                    leading: Icon(Icons.logout,color: AppColors.themeColor,),
                  ),
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
      height: size.height * .28,
      padding: const EdgeInsets.only(
        left: 48,
        right: 20,
        top: 20,
        bottom: 90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.themeColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(300, 70),
          bottomRight: Radius.elliptical(300, 70),
        ),
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Expanded(
            child: Text('Expense and Income Tracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: .w500,
              ),
              softWrap: true,
              maxLines: 2,
              textAlign: .center,
            ),
          ),
          _buildNotification(),
        ],
      ),
    );
  }
  Widget _buildNotification() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(48),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.notifications_none,
        color: Colors.white,
      ),
    );
  }
  Widget _buildProfile(Size size) {
    return Positioned(
      left: 24,
      right: 24,
      top: size.height *.22,
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage:AssetImage('assets/images/img.png'),
            radius: 48,
          ),
          const SizedBox(height: 8),
          Text('Md Bappy'),
        ],
      )
    );
  }
}
