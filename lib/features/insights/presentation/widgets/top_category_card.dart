import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class TopCategoryCard extends StatelessWidget {
  final String topCategory;
  final double amount;

  const TopCategoryCard({
    super.key,
    required this.topCategory,
    required this.amount,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Iconsax.cup;
      case 'transport':
        return Iconsax.car;
      case 'shopping':
        return Iconsax.bag_2;
      case 'health':
        return Iconsax.heart;
      case 'bills':
        return Iconsax.receipt_2;
      case 'salary':
        return Iconsax.money_recive;
      case 'savings':
        return Iconsax.save_2;
      case 'entertainment':
        return Iconsax.music;
      default:
        return Iconsax.more;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[topCategory.toLowerCase()] ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(topCategory),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Spending',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  topCategory.replaceFirst(
                    topCategory[0],
                    topCategory[0].toUpperCase(),
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(amount),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}