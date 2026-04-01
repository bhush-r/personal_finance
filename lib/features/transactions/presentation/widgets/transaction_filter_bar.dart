import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../../../core/theme/app_colors.dart';

class TransactionFilterBar extends StatelessWidget {
  final TransactionType? selectedType;
  final String searchQuery;
  final ValueChanged<TransactionType?> onTypeChanged;
  final ValueChanged<String> onSearchChanged;

  const TransactionFilterBar({
    super.key,
    required this.selectedType,
    required this.searchQuery,
    required this.onTypeChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            prefixIcon: const Icon(Icons.search, size: 20),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 10),
        // Type filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: selectedType == null,
                onTap: () => onTypeChanged(null),
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Income',
                isSelected: selectedType == TransactionType.income,
                onTap: () => onTypeChanged(TransactionType.income),
                color: AppColors.income,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Expense',
                isSelected: selectedType == TransactionType.expense,
                onTap: () => onTypeChanged(TransactionType.expense),
                color: AppColors.expense,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
