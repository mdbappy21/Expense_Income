import 'package:expense_income/presentation/ui/screen/home_screen.dart';
import 'package:expense_income/presentation/ui/screen/note_screen.dart';
import 'package:expense_income/presentation/ui/screen/profile_screen.dart';
import 'package:expense_income/presentation/ui/screen/statistics_screen.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';

class MainBottomNavBar extends StatefulWidget {
  const MainBottomNavBar({super.key});

  @override
  State<MainBottomNavBar> createState() => _MainBottomNavBarState();
}

class _MainBottomNavBarState extends State<MainBottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screen = [
    HomeScreen(),
    NoteScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_selectedIndex],

      // Center Floating Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        //todo on press FAB
        backgroundColor: AppColors.themeColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 24, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,

        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_rounded, index: 0),
              _buildNavItem(icon: Icons.edit_document, index: 1),

              const SizedBox(width: 40),

              _buildNavItem(icon: Icons.bar_chart_rounded, index: 2),
              _buildNavItem(icon: Icons.account_circle, index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    return IconButton(
      onPressed: () {
        if(mounted){
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      icon: Icon(
        icon,
        size: 28,
        color: _selectedIndex == index ? AppColors.themeColor : AppColors.themeColor2,
      ),
    );
  }
}
