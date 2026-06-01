import 'package:expense_income/presentation/state_holders/home_controller.dart';
import 'package:expense_income/presentation/state_holders/profile_controller.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: controller.loadHomeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildWelcomeNotification(
                        size,
                        controller.welcomeMessage,
                      ),
                      _buildSummary(
                        income: controller.income,
                        expense: controller.expense,
                        payable: controller.payable,
                        receivable: controller.receivable,
                        balance: controller.balance,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * .16),
                  _buildHistory(controller.transactions),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistory(List<Map<String, dynamic>> transactions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Transactions History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No transaction found'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final item = transactions[index];
                return _buildTransactionItem(item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> item) {
    final type = item['type'];
    final amount = (item['amount'] as num).toDouble();
    final date = DateTime.parse(item['date']);

    Color color;
    IconData icon;
    String sign;

    if (type == 'income') {
      color = Colors.green;
      icon = Icons.arrow_downward;
      sign = '+';
    } else if (type == 'expense') {
      color = Colors.red;
      icon = Icons.arrow_upward;
      sign = '-';
    } else if (type == 'payable') {
      color = Colors.red;
      icon = Icons.arrow_upward;
      sign = '-';
    } else if (type == 'receivable') {
      color = Colors.green;
      icon = Icons.arrow_downward;
      sign = '+';
    } else {
      color = Colors.grey;
      icon = Icons.help_outline;
      sign = '';
    }

    return Card(
      color: Colors.grey.shade200,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Icon(icon, color: color),
        ),
        title: Text(item['title'] ?? ''),
        subtitle: Text(
          DateFormat('dd MMM yyyy').format(date),
        ),
        trailing: Text(
          '$sign${amount.toStringAsFixed(2)} TK',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSummary({
    required double income,
    required double expense,
    required double payable,
    required double receivable,
    required double balance,
  }) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: -90,
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
        child: _buildBalanceSummary(
          income: income,
          expense: expense,
          payable: payable,
          receivable: receivable,
          balance: balance,
        ),
      ),
    );
  }

  Widget _buildBalanceSummary({
    required double income,
    required double expense,
    required double payable,
    required double receivable,
    required double balance,
  }) {
    return Column(
      children: [
        const Text(
          'Total Balance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${balance.toStringAsFixed(2)} TK',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,
          children: [
            _buildAmount(
              'Income',
              income,
              Colors.green,
              Colors.green.shade100,
              Icons.arrow_downward,
            ),
            _buildAmount(
              'Expense',
              expense,
              Colors.red,
              Colors.red.shade100,
              Icons.arrow_upward,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAmount(
              'Payable',
              payable,
              Colors.red,
              Colors.red.shade100,
              Icons.arrow_upward,
            ),
            _buildAmount(
              'Receivable',
              receivable,
              Colors.green,
              Colors.green.shade100,
              Icons.arrow_downward,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeNotification(
      Size size,
      String welcomeMessage,
      ) {
    return Container(
      width: double.infinity,
      height: size.height * .30,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 48,
        bottom: 100,
      ),
      decoration: const BoxDecoration(
        color: AppColors.themeColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(300, 70),
          bottomRight: Radius.elliptical(300, 70),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildWelcomeText(welcomeMessage),
          _buildNotification(),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(String welcomeMessage) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          welcomeMessage,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        GetBuilder<ProfileController>(
          builder: (controller) {
            return Text(
              controller.userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
            );
          },
        ),
      ],
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

  Widget _buildAmount(
      String category,
      double amount,
      Color iconColor,
      Color shadeColor,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            color: shadeColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(2)} TK',
              style: const TextStyle(
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