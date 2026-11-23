import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int id;
  final String type;

  const TransactionDetailScreen({
    super.key,
    required this.id,
    required this.type,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Map<String, dynamic>? transaction;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      transaction = await DatabaseHelper.instance.getTransactionDetail(
        type: widget.type,
        id: widget.id,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _title() {
    switch (widget.type) {
      case 'income':
        return 'Income Details';

      case 'expense':
        return 'Expense Details';

      case 'payable':
        return 'Payable Details';

      case 'receivable':
        return 'Receivable Details';

      default:
        return 'Transaction Details';
    }
  }

  Color _typeColor() {
    switch (widget.type) {
      case 'income':
        return Colors.green;

      case 'expense':
        return Colors.red;

      case 'payable':
        return Colors.orange;

      case 'receivable':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        backgroundColor: AppColors.themeColor,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transaction == null
          ? const Center(child: Text('Transaction not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _typeColor().withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.type.toUpperCase(),
                            style: TextStyle(
                              color: _typeColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildRow(
                        'Title',
                        transaction!['name'] ??
                            transaction!['category'] ??
                            transaction!['source'] ??
                            '-',
                      ),

                      _buildRow('Amount', '${transaction!['amount']} TK'),

                      _buildDateRow(),

                      _buildRow(
                        'Description',
                        transaction!['description']?.toString() ?? '-',
                      ),

                      if (widget.type == 'payable')
                        _buildRow(
                          'Status',
                          transaction!['is_returned'] == 1 ? 'Paid' : 'Pending',
                        ),

                      if (widget.type == 'receivable')
                        _buildRow(
                          'Status',
                          transaction!['is_received'] == 1
                              ? 'Received'
                              : 'Pending',
                        ),

                      if (widget.type == 'payable' &&
                          transaction!['return_date'] != null)
                        _buildRow(
                          'Return Date',
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(DateTime.parse(transaction!['return_date'])),
                        ),

                      if (widget.type == 'receivable' &&
                          transaction!['expected_date'] != null)
                        _buildRow(
                          'Expected Date',
                          DateFormat('dd MMM yyyy').format(
                            DateTime.parse(transaction!['expected_date']),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDateRow() {
    String? date;

    if (widget.type == 'income') {
      date = transaction!['date'];
    }

    if (widget.type == 'expense') {
      date = transaction!['date'];
    }

    if (widget.type == 'payable') {
      date = transaction!['payable_date'];
    }

    if (widget.type == 'receivable') {
      date = transaction!['expected_date'];
    }

    if (date == null) {
      return const SizedBox();
    }

    return _buildRow(
      'Date',
      DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$title :',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
