import 'package:expense_income/app.dart';
import 'package:expense_income/presentation/state_holders/notification_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  runApp(
    const ExpenseIncome(),
  );
}
