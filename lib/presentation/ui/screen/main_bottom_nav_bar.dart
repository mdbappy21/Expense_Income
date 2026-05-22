import 'package:expense_income/presentation/ui/screen/add_borrow_screen.dart';
import 'package:expense_income/presentation/ui/screen/add_expense_screen.dart';
import 'package:expense_income/presentation/ui/screen/add_income_screen.dart';
import 'package:expense_income/presentation/ui/screen/home_screen.dart';
import 'package:expense_income/presentation/ui/screen/note_screen.dart';
import 'package:expense_income/presentation/ui/screen/profile_screen.dart';
import 'package:expense_income/presentation/ui/screen/statistics_screen.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        onPressed:(){
          _onTapFAB(context);
        } ,
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

  void _onTapFAB(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        size.width / 3,
        size.height*.685,
        size.width / 3,
        0,
      ),
      items: [
        const PopupMenuItem(
          value: 'income',
          child: Text('Add Income'),
        ),
        const PopupMenuItem(
          value: 'expense',
          child: Text('Add Expense'),
        ),
        const PopupMenuItem(
          value: 'borrow',
          child: Text('Add Borrow'),
        ),
      ],
    );

    if (selected == 'income') {
      Get.to(()=>AddIncomeScreen());
    } else if (selected == 'expense') {
      Get.to(()=>AddExpenseScreen());
    }else if (selected == 'borrow') {
      Get.to(()=>AddBorrowScreen());
    }
  }
}
