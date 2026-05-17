import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:expense_income/presentation/ui/widgets/transaction_item.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildWelcomeNotification(size),
                  _buildSummary(),
                ],
              ),
              SizedBox(height: size.height*.12),
              _buildHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text('Transactions History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (context, index) {
              return const TransactionItem();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: -72,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.themeColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(72),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _buildBalanceSummary(),
      ),
    );
  }

  Widget _buildBalanceSummary() {
    return Column(
      children: [
        Column(
          children: [
            Text('Total Balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text('2,548.00 TK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAmount('Income', 10000.00, Colors.green, Colors.green.shade100, Icons.arrow_downward),
            _buildAmount('Expense', 100.00, Colors.red, Colors.red.shade100, Icons.arrow_upward),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAmount('Borrow', 100.00, Colors.black, Colors.orange.shade100, Icons.arrow_downward),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeNotification(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * .28,
      padding: const EdgeInsets.only(
        left: 20,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeText(),
          _buildNotification(),
        ],
      ),
    );
  }

  Widget _buildNotification() {
    return Container(
      padding: const EdgeInsets.all(10),
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

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Good afternoon,',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),

        SizedBox(height: 6),
        Text('Md Bappy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildAmount(String category,double amount,Color iconColor,Color shadeColor,IconData icon) {
    return Row(
      children: [
        Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            color: shadeColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(icon,
            color: iconColor,
            size: 12,
          ),
        ),

        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(category,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 4),

            Text('$amount TK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
