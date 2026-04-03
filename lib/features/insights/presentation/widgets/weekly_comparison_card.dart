import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WeeklyComparisonCard extends StatelessWidget {
  final double thisWeek;
  final double lastWeek;

  const WeeklyComparisonCard({
    super.key,
    required this.thisWeek,
    required this.lastWeek,
  });

  @override
  Widget build(BuildContext context) {
    final diff = thisWeek - lastWeek;
    final isUp = diff > 0;
    final pct =
    lastWeek > 0 ? (diff.abs() / lastWeek * 100).toStringAsFixed(1) : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Comparison',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WeekCol(
                  label: 'This Week',
                  amount: thisWeek,
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WeekCol(
                  label: 'Last Week',
                  amount: lastWeek,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isUp ? AppColors.expense : AppColors.income,
              ),
              const SizedBox(width: 4),
              Text(
                lastWeek > 0
                    ? '$pct% ${isUp ? 'more' : 'less'} than last week'
                    : 'No data for last week',
                style: TextStyle(
                  color: isUp ? AppColors.expense : AppColors.income,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekCol extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _WeekCol({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}