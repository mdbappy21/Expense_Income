import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/state_holders/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  late Future<Map<String, List<Map<String, dynamic>>>> _dataFuture;
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = _getPaymentData();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _getPaymentData() async {
    final db = DatabaseHelper.instance;
    final receivables = await db.getReceivables();
    final payables = await db.getPayables();

    final lent = <Map<String, dynamic>>[];
    for (final item in receivables.where((e) => e['is_received'] == 0)) {
      final id = (item['id'] as num).toInt();
      lent.add({
        ...item,
        'remaining_balance': await db.getReceivableRemainingBalance(id),
      });
    }

    final borrowed = <Map<String, dynamic>>[];
    for (final item in payables.where((e) => e['is_returned'] == 0)) {
      final id = (item['id'] as num).toInt();
      borrowed.add({
        ...item,
        'remaining_balance': await db.getPayableRemainingBalance(id),
      });
    }

    return {'lent': lent, 'borrowed': borrowed};
  }

  double _getTotal(List<Map<String, dynamic>> items) {
    return items.fold<double>(
      0,
          (total, item) =>
      total + ((item['remaining_balance'] as num?)?.toDouble() ?? 0),
    );
  }

  String _formatAmount(double amount) =>
      '৳${_currencyFormat.format(amount)}';

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Not set';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return 'Not set';
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  void _showMessage(String title, String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title: $message'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(_loadData);
    await _dataFuture;
  }

  Future<void> _showRecordPaymentDialog(
      Map<String, dynamic> item, {
        required bool isLent,
      }) async {
    final id = (item['id'] as num).toInt();
    final name = (isLent ? item['source'] : item['name']).toString();
    final remaining = (item['remaining_balance'] as num).toDouble();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    DateTime paymentDate = DateTime.now();
    DateTime? nextDate;
    bool isSaving = false;
    String? validationError;
    String? saveError;
    bool saved = false;
    double? savedAmount;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: Text(
                  isLent ? 'Record Money Received' : 'Record Payment',
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text('Remaining: ${_formatAmount(remaining)}'),
                      const SizedBox(height: 16),
                      TextField(
                        controller: amountController,
                        enabled: !isSaving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) {
                          if (validationError != null) {
                            setDialogState(() => validationError = null);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '৳ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (validationError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          validationError!,
                          style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: paymentDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            helpText: 'Select payment date',
                          );
                          if (picked != null) {
                            setDialogState(() => paymentDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          'Payment date: ${_formatDate(paymentDate.toIso8601String())}',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        enabled: !isSaving,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                          final existingDate = isLent
                              ? item['expected_date']?.toString()
                              : item['return_date']?.toString();
                          final today = DateTime.now();
                          final todayDate = DateTime(
                            today.year,
                            today.month,
                            today.day,
                          );
                          final parsedExisting = existingDate == null
                              ? todayDate
                              : DateTime.tryParse(existingDate) ??
                              todayDate;
                          final safeExisting =
                          parsedExisting.isBefore(todayDate)
                              ? todayDate
                              : parsedExisting;

                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: nextDate ?? safeExisting,
                            firstDate: todayDate,
                            lastDate: DateTime(2100),
                            helpText: isLent
                                ? 'Next expected collection date'
                                : 'Next payment due date',
                          );
                          if (picked != null) {
                            setDialogState(() => nextDate = picked);
                          }
                        },
                        icon: const Icon(Icons.event_available_outlined),
                        label: Text(
                          nextDate == null
                              ? 'Set next expected date (optional)'
                              : 'Next date: ${_formatDate(nextDate!.toIso8601String())}',
                        ),
                      ),
                      if (nextDate != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isSaving
                                ? null
                                : () => setDialogState(() => nextDate = null),
                            child: const Text('Clear next date'),
                          ),
                        ),
                      if (saveError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          saveError!,
                          style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                      final amount = double.tryParse(
                        amountController.text.trim(),
                      );

                      if (amount == null ||
                          !amount.isFinite ||
                          amount <= 0) {
                        setDialogState(() {
                          validationError =
                          'Enter an amount greater than zero.';
                        });
                        return;
                      }

                      if (amount > remaining + 0.000001) {
                        setDialogState(() {
                          validationError =
                          'The amount cannot exceed the remaining balance.';
                        });
                        return;
                      }

                      setDialogState(() {
                        isSaving = true;
                        validationError = null;
                        saveError = null;
                      });

                      try {
                        final db = DatabaseHelper.instance;
                        if (isLent) {
                          await db.recordReceivablePayment(
                            receivableId: id,
                            amount: amount,
                            paymentDate: paymentDate,
                            note: noteController.text.trim(),
                            nextExpectedDate: nextDate,
                          );
                        } else {
                          await db.recordPayablePayment(
                            payableId: id,
                            amount: amount,
                            paymentDate: paymentDate,
                            note: noteController.text.trim(),
                            nextReturnDate: nextDate,
                          );
                        }

                        if (Get.isRegistered<NotificationController>()) {
                          final notifications =
                          Get.find<NotificationController>();
                          await notifications.ensureReady();
                          await notifications.rescheduleAllReminders();
                          await notifications.loadNotifications();
                        }

                        saved = true;
                        savedAmount = amount;
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      } catch (e) {
                        setDialogState(() {
                          isSaving = false;
                          saveError = 'Unable to save: $e';
                        });
                      }
                    },
                    child: isSaving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(isLent ? 'Record Received' : 'Record Payment'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (saved && savedAmount != null) {
        await _refresh();
        final isSettled = savedAmount! >= remaining - 0.000001;
        _showMessage(
          'Success',
          isSettled
              ? (isLent
              ? 'Money received. Record settled.'
              : 'Payment recorded. Record settled.')
              : (isLent
              ? 'Received amount recorded.'
              : 'Payment recorded.'),
        );
      }
    } finally {
      amountController.dispose();
      noteController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Management'),
          centerTitle: true,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          bottom: TabBar(
            labelColor: colors.onPrimary,
            unselectedLabelColor: colors.onPrimary.withValues(alpha: 0.70),
            indicatorColor: colors.onPrimary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Lent Money'),
              Tab(text: 'Borrowed Money'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Unable to load payment records: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = snapshot.data ?? {};
            final lent = data['lent'] ?? [];
            final borrowed = data['borrowed'] ?? [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          context,
                          title: 'To Receive',
                          amount: _getTotal(lent),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          context,
                          title: 'To Pay',
                          amount: _getTotal(borrowed),
                          color: colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildList(context, items: lent, isLent: true),
                      _buildList(context, items: borrowed, isLent: false),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryCard(
      BuildContext context, {
        required String title,
        required double amount,
        required Color color,
      }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      BuildContext context, {
        required List<Map<String, dynamic>> items,
        required bool isLent,
      }) {
    final colors = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLent
                  ? Icons.handshake_outlined
                  : Icons.account_balance_wallet_outlined,
              size: 64,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              isLent
                  ? 'No outstanding lent money'
                  : 'No outstanding borrowed money',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final id = (item['id'] as num).toInt();
          final name = (isLent ? item['source'] : item['name']).toString();
          final date = isLent
              ? item['expected_date']?.toString()
              : item['return_date']?.toString();
          final remaining = (item['remaining_balance'] as num).toDouble();
          final original = (item['amount'] as num).toDouble();
          final paid = (original - remaining).clamp(0.0, original).toDouble();

          return Card(
            color: colors.surfaceContainer,
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isLent
                            ? Colors.green.withValues(alpha: 0.12)
                            : colors.error.withValues(alpha: 0.12),
                        child: Icon(
                          isLent ? Icons.call_received : Icons.call_made,
                          color: isLent ? Colors.green : colors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${isLent ? 'Expected to receive' : 'Expected to pay'}: ${_formatDate(date)}',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Original: ${_formatAmount(original)}',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Paid: ${_formatAmount(paid)}',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatAmount(remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isLent ? Colors.green : colors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          _showRecordPaymentDialog(item, isLent: isLent),
                      icon: Icon(isLent ? Icons.add : Icons.payment),
                      label: Text(
                        isLent ? 'Record Received Amount' : 'Record Payment',
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Record ID $id',
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
