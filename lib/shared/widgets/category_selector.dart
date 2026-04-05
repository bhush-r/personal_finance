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

  IconData _getIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Iconsax.cup;
      case TransactionCategory.transport:
        return Iconsax.car;
      case TransactionCategory.shopping:
        return Iconsax.bag;
      case TransactionCategory.health:
        return Iconsax.heart;
      case TransactionCategory.bills:
        return Iconsax.receipt;
      case TransactionCategory.salary:
        return Iconsax.money_recive;
      case TransactionCategory.savings:
        return Iconsax.save_2;
      case TransactionCategory.entertainment:
        return Iconsax.music;
      default:
        return Iconsax.more;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 12),

        /// 🔥 GRID STYLE (premium)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
          children: TransactionCategory.values.map((cat) {
            final isSelected = cat == selected;

            final color =
                AppColors.categoryColors[cat.name] ?? AppColors.primary;

            return GestureDetector(
              onTap: () => onSelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIcon(cat),
                      color: isSelected ? color : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                        isSelected ? color : Colors.grey.shade700,
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