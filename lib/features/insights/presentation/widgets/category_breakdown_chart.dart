import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryBreakdownChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 10),
                Text(
                  'No spending data',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final total = data.values.fold<double>(0, (a, b) => a + b);
    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✨ PIE CHART
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: sortedData.map((e) {
                  final color = AppColors.categoryColors[e.key] ??
                      AppColors.primary;
                  final percentage = ((e.value / total) * 100);

                  return PieChartSectionData(
                    value: e.value,
                    title: percentage > 5
                        ? '${percentage.toStringAsFixed(0)}%'
                        : '',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    color: color,
                  );
                }).toList(),
                centerSpaceRadius: 0,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),
          const SizedBox(height: 16),

          // ✨ LEGEND
          Column(
            children: sortedData.map((e) {
              final color =
                  AppColors.categoryColors[e.key] ?? AppColors.primary;
              final percentage =
              ((e.value / total) * 100).toStringAsFixed(1);
              final displayName = e.key.isEmpty
                  ? 'Other'
                  : e.key[0].toUpperCase() + e.key.substring(1);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayName,
                        style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$percentage%',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(e.value),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Dummy import for CurrencyFormatter
class CurrencyFormatter {
  static String format(double amount) {
    return amount.toStringAsFixed(0);
  }
}