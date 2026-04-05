import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../core/theme/app_colors.dart';

class CategorySelector extends StatelessWidget {
  final TransactionCategory selected;
  final Function(TransactionCategory) onSelected;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Iconsax.cup;
      case TransactionCategory.transport:
        return Iconsax.car;
      case TransactionCategory.shopping:
        return Iconsax.bag_2;
      case TransactionCategory.health:
        return Iconsax.heart;
      case TransactionCategory.bills:
        return Iconsax.receipt_2;
      case TransactionCategory.salary:
        return Iconsax.money_recive;
      case TransactionCategory.savings:
        return Iconsax.save_2;
      case TransactionCategory.entertainment:
        return Iconsax.music;
      case TransactionCategory.other:
        return Iconsax.more;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionCategory.values.map((cat) {
            final isSelected = cat == selected;
            return GestureDetector(
              onTap: () => onSelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.categoryColors[cat.name.toLowerCase()] ?? AppColors.primary
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(cat),
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.name.replaceFirst(cat.name[0], cat.name[0].toUpperCase()),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}