import 'package:expense_income/controller_binders.dart';
import 'package:expense_income/presentation/state_holders/theme_controller.dart';
import 'package:expense_income/presentation/ui/screen/splash_screen.dart';
import 'package:expense_income/presentation/ui/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseIncome extends StatelessWidget {
  const ExpenseIncome({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      initialBinding: ControllerBinder(),
      debugShowCheckedModeBanner: false,
      title: 'Spendora',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: SplashScreen(),
    );
  }
}
