// lib/features/transactions/presentation/widgets/transaction_tile.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Optimization: RepaintBoundary isolates this tile's paint layer
    return RepaintBoundary(
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: _buildDeleteBackground(),
        child: _buildTileContent(context),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Iconsax.trash, color: Colors.white),
    );
  }

  Widget _buildTileContent(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final categoryColor = AppColors.categoryColors[transaction.category.name.toLowerCase()] ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            _buildCategoryIcon(categoryColor),
            const SizedBox(width: 12),
            _buildInfoSection(context),
            _buildAmountSection(isIncome, color),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(_getIconForCategory(transaction.category), color: color, size: 22),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.category.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (transaction.note.isNotEmpty)
            Text(
              transaction.note,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            DateFormatter.formatDate(transaction.date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(bool isIncome, Color color) {
    return Text(
      '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14),
    );
  }

  IconData _getIconForCategory(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food: return Iconsax.cup;
      case TransactionCategory.transport: return Iconsax.car;
      case TransactionCategory.shopping: return Iconsax.bag_2;
      case TransactionCategory.health: return Iconsax.heart;
      case TransactionCategory.bills: return Iconsax.receipt_2;
      case TransactionCategory.salary: return Iconsax.money_recive;
      case TransactionCategory.savings: return Iconsax.save_2;
      case TransactionCategory.entertainment: return Iconsax.music;
      default: return Iconsax.more;
    }
  }
}