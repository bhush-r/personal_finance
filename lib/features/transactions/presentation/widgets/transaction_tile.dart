import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../../../core/theme/app_colors.dart';
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
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final categoryColor =
        AppColors.categoryColors[transaction.category.name] ?? AppColors.primary;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.expense.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.expense),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _emojiForCategory(transaction.category),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.note.isNotEmpty
                          ? transaction.note
                          : _labelForCategory(transaction.category),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _labelForCategory(transaction.category),
                            style: TextStyle(
                                fontSize: 10,
                                color: categoryColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.formatShort(transaction.date),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
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

  String _labelForCategory(TransactionCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }
}
