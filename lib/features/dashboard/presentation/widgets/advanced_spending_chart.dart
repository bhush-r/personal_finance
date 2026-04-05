import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class AdvancedSpendingChart extends StatefulWidget {
  final Map<String, double> categoryData;

  const AdvancedSpendingChart({super.key, required this.categoryData});

  @override
  State<AdvancedSpendingChart> createState() => _AdvancedSpendingChartState();
}

class _AdvancedSpendingChartState extends State<AdvancedSpendingChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryData.isEmpty) {
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

    final total = widget.categoryData.values.fold<double>(0, (a, b) => a + b);

    // Convert entries to list first, then use asMap()
    final entries = widget.categoryData.entries.toList();
    final chartData = entries.asMap().entries.map((e) {
      final isTouched = e.key == _touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;

      return PieChartSectionData(
        color: AppColors.categoryColors[e.value.key] ?? AppColors.primary,
        value: e.value.value,
        title: '${((e.value.value / total) * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _Badge(
          '${e.value.key.substring(0, 1).toUpperCase()}',
          isTouched ? 20 : 16,
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    // Check if touch event is valid
                    if (pieTouchResponse == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: chartData,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Column(
      children: widget.categoryData.entries.map((e) {
        final color = AppColors.categoryColors[e.key] ?? AppColors.primary;
        final total = widget.categoryData.values.fold<double>(0, (a, b) => a + b);
        final percentage = ((e.value / total) * 100).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
              const SizedBox(width: 8),
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
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final double size;

  const _Badge(this.label, this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: size / 2,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}