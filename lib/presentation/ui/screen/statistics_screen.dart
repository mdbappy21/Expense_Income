import 'package:expense_income/presentation/state_holders/statistics_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatisticsController>(
      init: StatisticsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xfffbfbfb),
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
                  _buildHeader(controller),
                  const SizedBox(height: 28),
                  _buildPeriodTabs(controller),
                  const SizedBox(height: 22),
                  _buildDropdown(controller),
                  const SizedBox(height: 20),
                  _buildChart(controller),
                  const SizedBox(height: 32),
                  _buildTopSection(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(StatisticsController controller) {
    return Row(
      children: [
        InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
        const Spacer(),
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: controller.exportPdf,
          child: const Icon(Icons.file_download_outlined),
        ),
      ],
    );
  }

  Widget _buildPeriodTabs(StatisticsController controller) {
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
                color: isSelected ? const Color(0xff2f7d73) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDropdown(StatisticsController controller) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedType,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: controller.types.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
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

  Widget _buildChart(StatisticsController controller) {
    if (controller.chartSpots.isEmpty) {
      return const SizedBox(
        height: 190,
        child: Center(child: Text('No chart data')),
      );
    }

    final maxY = controller.chartSpots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: controller.chartSpots.length > 1
              ? controller.chartSpots.length - 1
              : 1,
          minY: 0,
          maxY: maxY == 0 ? 10 : maxY + (maxY * .2),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= controller.transactions.length) {
                    return const SizedBox();
                  }

                  final date = DateTime.parse(
                    controller.transactions[index]['date'],
                  );

                  return Text(
                    DateFormat('dd MMM').format(date),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: controller.chartSpots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withAlpha(30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(StatisticsController controller) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              controller.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.swap_vert),
          ],
        ),
        const SizedBox(height: 14),
        if (controller.transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No data found'),
          )
        else
          ListView.builder(
            itemCount: controller.transactions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = controller.transactions[index];

              return _buildTopItem(
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
    required StatisticsController controller,
    required String title,
    required String date,
    required double amount,
    required bool isSelected,
  }) {
    final parsedDate = DateTime.parse(date);

    final bool isExpense = controller.selectedType == 'Expense';

    final Color mainColor = isExpense
        ? Colors.red
        : controller.selectedType == 'Income'
        ? Colors.green
        : Colors.orange;

    final IconData icon = isExpense
        ? Icons.arrow_upward
        : controller.selectedType == 'Income'
        ? Icons.arrow_downward
        : Icons.handshake;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xff2f7d73) : Colors.white,
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
            backgroundColor:
            isSelected ? Colors.white24 : mainColor.withAlpha(30),
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
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(parsedDate),
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'} ${amount.toStringAsFixed(2)} TK',
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