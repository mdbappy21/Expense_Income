import 'package:expense_income/presentation/state_holders/statistics_controller.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;

    return GetBuilder<StatisticsController>(
      init: StatisticsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.themeColor,
            centerTitle: true,
            title: const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  controller.exportPdf;
                },
                icon: const Icon(Icons.file_download_outlined),
                color: Colors.white,
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SafeArea(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        _buildPeriodTabs(context, controller),
                        const SizedBox(height: 16),
                        _buildDropdown(context, controller),
                        const SizedBox(height: 16),
                        _buildChart(context, controller),
                        const SizedBox(height: 32),
                        _buildTopSection(context, controller),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodTabs(
    BuildContext context,
    StatisticsController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.periods.map((period) {
          final bool isSelected = controller.selectedPeriod == period;

          return GestureDetector(
            onTap: () => controller.changePeriod(period),
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.themeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, StatisticsController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedType,
            dropdownColor: colorScheme.surface,
            style: TextStyle(color: colorScheme.onSurface),
            icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
            items: controller.types.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.changeType(value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, StatisticsController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    if (controller.chartSpots.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Text(
            'No chart data',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final highestY = controller.chartSpots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);

    final chartWidth = (controller.chartSpots.length * 80.0)
        .clamp(350.0, 5000.0)
        .toDouble();

    final yPadding = highestY == 0 ? 10.0 : highestY * 0.25;

    return SizedBox(
      height: 260,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: controller.chartSpots.last.x + 0.05,
                minY: 0,
                maxY: highestY + yPadding,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: highestY <= 0 ? 1 : highestY / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();

                        if (index < 0 ||
                            index >= controller.chartLabels.length) {
                          return const SizedBox.shrink();
                        }

                        if (value != index.toDouble()) {
                          return const SizedBox.shrink();
                        }

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            controller.chartLabels[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: controller.chartSpots,
                    isCurved: false,
                    barWidth: 3,
                    color: Colors.blue,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withAlpha(32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    StatisticsController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Text(
              controller.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(Icons.swap_vert, color: colorScheme.onSurfaceVariant),
          ],
        ),
        const SizedBox(height: 14),
        if (controller.transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No data found',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          ListView.builder(
            itemCount: controller.transactions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = controller.transactions[index];

              return _buildTopItem(
                context: context,
                controller: controller,
                title: item['title'] ?? '',
                date: item['date'],
                amount: (item['amount'] as num).toDouble(),
                isSelected: index == 0,
              );
            },
          ),
      ],
    );
  }

  Widget _buildTopItem({
    required BuildContext context,
    required StatisticsController controller,
    required String title,
    required String date,
    required double amount,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final parsedDate = DateTime.parse(date);

    Color mainColor;
    IconData icon;
    String sign;

    switch (controller.selectedType) {
      case 'Income':
        mainColor = Colors.green;
        icon = Icons.arrow_downward;
        sign = '+';
        break;

      case 'Expense':
        mainColor = Colors.red;
        icon = Icons.arrow_upward;
        sign = '-';
        break;

      case 'Borrow':
        mainColor = Colors.orange;
        icon = Icons.payments_outlined;
        sign = '-';
        break;

      case 'Lend':
        mainColor = Colors.blue;
        icon = Icons.account_balance_wallet_outlined;
        sign = '+';
        break;

      default:
        mainColor = Colors.grey;
        icon = Icons.help_outline;
        sign = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.themeColor : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isSelected
                ? Colors.white24
                : mainColor.withAlpha(30),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : mainColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(parsedDate),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white70
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign ${amount.toStringAsFixed(2)} TK',
            style: TextStyle(
              color: isSelected ? Colors.white : mainColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
