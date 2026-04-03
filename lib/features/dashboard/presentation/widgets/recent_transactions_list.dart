import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No transactions yet',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: [
        ...transactions.map((t) => _TransactionRow(transaction: t)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.go('/transactions'),
          child: Text(
            'View all transactions →',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final categoryColor =
        AppColors.categoryColors[transaction.category.name] ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _emojiForCategory(transaction.category),
                style: const TextStyle(fontSize: 18),
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
                      fontWeight: FontWeight.w500, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormatter.formatShort(transaction.date),
                  style:
                  const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
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

  String _labelForCategory(TransactionCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }
}