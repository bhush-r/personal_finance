import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final double averageDailySpend;
  final double thisWeekExpense;

  const ExpenseSummaryCard({
    super.key,
    required this.averageDailySpend,
    required this.thisWeekExpense,
  });

  @override
  Widget build(BuildContext context) {
    final projectedMonthly = averageDailySpend * 30;
    final remainingInWeek = (averageDailySpend * 7) - thisWeekExpense;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.calculator,
                  color: AppColors.expense,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Average",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(averageDailySpend),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            icon: Iconsax.trend_up,
            label: "Projected Monthly",
            amount: projectedMonthly,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            context,
            icon: Iconsax.wallet_2,
            label: "Remaining This Week",
            amount: remainingInWeek.isNegative ? 0 : remainingInWeek,
            color: remainingInWeek.isNegative ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required double amount,
        required Color color,
      }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}