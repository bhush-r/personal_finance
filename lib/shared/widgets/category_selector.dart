import 'package:flutter/material.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../core/theme/app_colors.dart';

class CategorySelector extends StatelessWidget {
  final TransactionCategory selected;
  final ValueChanged<TransactionCategory> onSelected;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionCategory.values.map((cat) {
            final isSelected = cat == selected;
            final color =
                AppColors.categoryColors[cat.name] ?? AppColors.primary;
            final label = cat.name[0].toUpperCase() + cat.name.substring(1);

            return GestureDetector(
              onTap: () => onSelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _emojiForCategory(cat),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
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