import 'package:expense_income/presentation/ui/screen/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class ExpenseIncome extends StatelessWidget {
  const ExpenseIncome({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainBottomNavBar(),
    );
  }
}