import 'package:expense_income/app.dart';
import 'package:expense_income/presentation/state_holders/notification_service.dart';
import 'package:expense_income/presentation/state_holders/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  final themeController = ThemeController();
  await themeController.loadThemeMode();

  Get.put<ThemeController>(themeController, permanent: true);

  runApp(const ExpenseIncome());
}
