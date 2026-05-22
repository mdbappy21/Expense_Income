import 'package:expense_income/presentation/ui/screen/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'presentation/ui/utils/app_colors.dart';

class ExpenseIncome extends StatelessWidget {
  const ExpenseIncome({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _lightThemeData(),
      home: MainBottomNavBar(),
    );
  }

  ThemeData _lightThemeData() => ThemeData(
      brightness: Brightness.light,
      inputDecorationTheme: InputDecorationTheme(
        border: _outlineInputBorder(),
        enabledBorder: _outlineInputBorder(Colors.teal),
        filled: true,
        fillColor: Colors.transparent,
        focusedBorder: _outlineInputBorder(Colors.orange),
        errorBorder: _outlineInputBorder(Colors.red),
        hintStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          fixedSize: const Size(double.maxFinite, 50),
        ),
      ),
  );

  OutlineInputBorder _outlineInputBorder([Color? color]) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color ?? AppColors.themeColor, width: 1.2),
      borderRadius: BorderRadius.circular(8),
    );
  }
}