import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

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
    final change = lastWeek == 0 ? 0 : ((thisWeek - lastWeek) / lastWeek) * 100;
    final isDecreased = change < 0; // Spending decreased is good
    final difference = (thisWeek - lastWeek).abs();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.level,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Weekly Comparison',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildWeekCard(
                  context,
                  label: 'This Week',
                  amount: thisWeek,
                  isActive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWeekCard(
                  context,
                  label: 'Last Week',
                  amount: lastWeek,
                  isActive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDecreased ? Colors.green : AppColors.expense)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDecreased ? Colors.green : AppColors.expense)
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDecreased ? Icons.trending_down : Icons.trending_up,
                      color:
                      isDecreased ? Colors.green : AppColors.expense,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDecreased
                          ? '${change.abs().toStringAsFixed(1)}% Lower'
                          : '${change.abs().toStringAsFixed(1)}% Higher',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDecreased ? Colors.green : AppColors.expense,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.format(difference),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDecreased ? Colors.green : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(
      BuildContext context, {
        required String label,
        required double amount,
        required bool isActive,
      }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(amount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}