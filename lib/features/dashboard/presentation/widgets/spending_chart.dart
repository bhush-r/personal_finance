import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class SpendingChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const SpendingChart({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No spending data',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final total = categoryData.values.fold<double>(0.0, (a, b) => a + b);
    final chartData = categoryData.entries
        .map((e) => PieChartSectionData(
      value: e.value,
      title: '${((e.value / total) * 100).toStringAsFixed(0)}%',
      radius: 50,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      color: AppColors.categoryColors[e.key] ?? AppColors.primary,
    ))
        .toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: chartData,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}
