import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../transactions/domain/entities/transaction.dart';

class SpendingChart extends StatefulWidget {
  final Map<TransactionCategory, double> categoryData;
  const SpendingChart({super.key, required this.categoryData});

  @override
  State<SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<SpendingChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryData.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No expense data yet', style: TextStyle(color: Colors.grey)),
      );
    }

    final sections = _buildSections();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: sections,
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.categoryData.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _colorForCategory(e.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _labelForCategory(e.key),
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = widget.categoryData.values.fold(0.0, (a, b) => a + b);
    final entries = widget.categoryData.entries.toList();
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final value = entries[i].value;
      return PieChartSectionData(
        color: _colorForCategory(entries[i].key),
        value: value,
        title: '${(value / total * 100).toStringAsFixed(0)}%',
        radius: isTouched ? 60 : 50,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      );
    });
  }

  Color _colorForCategory(TransactionCategory cat) {
    return AppColors.categoryColors[cat.name] ?? AppColors.primary;
  }

  String _labelForCategory(TransactionCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }
}