import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
  }

  Future<Map<String, dynamic>> _loadHomeData() async {
    final income = await DatabaseHelper.instance.getIncomeTotal();
    final expense = await DatabaseHelper.instance.getExpenseTotal();
    final borrow = await DatabaseHelper.instance.getBorrowTotal();
    final transactions = await DatabaseHelper.instance.getAllTransactions();

    return {
      'income': income,
      'expense': expense,
      'borrow': borrow,
      'balance': income + borrow - expense,
      'transactions': transactions,
    };
  }

  String _welcomeMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning,';
    } else if (hour >= 12 && hour < 14) {
      return 'Good noon,';
    } else if (hour >= 14 && hour < 17) {
      return 'Good afternoon,';
    } else if (hour >= 17 && hour < 20) {
      return 'Good evening,';
    } else {
      return 'Good night,';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _homeDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? {};
            final income = data['income'] ?? 0.0;
            final expense = data['expense'] ?? 0.0;
            final borrow = data['borrow'] ?? 0.0;
            final balance = data['balance'] ?? 0.0;
            final transactions =
                data['transactions'] as List<Map<String, dynamic>>? ?? [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildWelcomeNotification(size),
                      _buildSummary(
                        income: income,
                        expense: expense,
                        borrow: borrow,
                        balance: balance,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * .12),
                  _buildHistory(transactions),
                ],
              ),
            );
          },
        ),
      ),
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
    } else {
      color = Colors.orange;
      icon = Icons.handshake;
      sign = '+';
    }

    return Card(
      color: Colors.grey.shade200,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Icon(icon, color: color),
        ),
        title: Text(item['title'] ?? ''),
        subtitle: Text(DateFormat('dd MMM yyyy').format(date)),
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
    required double borrow,
    required double balance,
  }) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: -72,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
          borrow: borrow,
          balance: balance,
        ),
      ),
    );
  }

  Widget _buildBalanceSummary({required double income, required double expense, required double borrow, required double balance,}) {
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAmount('Income', income, Colors.green, Colors.green.shade100,
                Icons.arrow_downward),
            _buildAmount('Expense', expense, Colors.red, Colors.red.shade100,
                Icons.arrow_upward),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: .center,
          children: [
            _buildAmount('Borrow', borrow, Colors.orange, Colors.orange.shade100,
                Icons.handshake),
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

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _welcomeMessage(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Md Bappy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
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
          child: Icon(icon, color: iconColor, size: 12),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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