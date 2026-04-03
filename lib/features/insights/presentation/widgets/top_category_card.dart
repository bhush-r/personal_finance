import 'package:flutter/material.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../../core/theme/app_colors.dart';

class TopCategoryCard extends StatelessWidget {
  final TransactionCategory? topCategory;
  final double amount;

  const TopCategoryCard({
    super.key,
    required this.topCategory,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    if (topCategory == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No expense data yet',
            style: TextStyle(color: Colors.grey)),
      );
    }

    final color =
        AppColors.categoryColors[topCategory!.name] ?? AppColors.primary;
    final label =
        topCategory!.name[0].toUpperCase() + topCategory!.name.substring(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              _emojiForCategory(topCategory!),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Spending',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _emojiForCategory(TransactionCategory cat) {
    const emojis = {
      TransactionCategory.food: '🍔',
      TransactionCategory.transport: '🚗',
      TransactionCategory.shopping: '🛍️',
      TransactionCategory.health: '💊',
      TransactionCategory.bills: '💡',
      TransactionCategory.salary: '💰',
      TransactionCategory.savings: '🏦',
      TransactionCategory.entertainment: '🎬',
      TransactionCategory.other: '📦',
    };
    return emojis[cat] ?? '📦';
  }
}