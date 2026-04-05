import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryBreakdownChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 250,
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

    final total = data.values.fold<double>(0, (a, b) => a + b);
    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sortedData.map((e) {
                final color = AppColors.categoryColors[e.key] ?? AppColors.primary;
                return PieChartSectionData(
                  value: e.value,
                  title: '${((e.value / total) * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: color,
                );
              }).toList(),
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...sortedData.map((e) {
          final color = AppColors.categoryColors[e.key] ?? AppColors.primary;
          final percentage = ((e.value / total) * 100).toStringAsFixed(1);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.key.replaceFirst(e.key[0], e.key[0].toUpperCase()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}