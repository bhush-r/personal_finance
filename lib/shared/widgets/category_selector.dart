import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../core/theme/app_colors.dart';

class CategorySelector extends StatefulWidget {
  final TransactionCategory selected;
  final Function(TransactionCategory) onSelected;
  final bool showLabels;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.showLabels = true,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
          children: TransactionCategory.values.map((cat) {
            final isSelected = cat == widget.selected;
            final color =
                AppColors.categoryColors[cat.name] ?? AppColors.primary;

            return ScaleTransition(
              scale: isSelected
                  ? Tween<double>(begin: 1.0, end: 1.05).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
              )
                  : AlwaysStoppedAnimation(1.0),
              child: GestureDetector(
                onTap: () {
                  widget.onSelected(cat);
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIcon(cat),
                        color: isSelected ? color : Colors.grey.shade600,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      if (widget.showLabels)
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}