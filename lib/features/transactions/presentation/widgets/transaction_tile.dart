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
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;

    final categoryColor =
        AppColors.categoryColors[transaction.category.name] ??
            AppColors.primary;

    return Dismissible(
      key: Key(transaction.id),

      /// 👉 Swipe only from right to left
      direction: DismissDirection.endToStart,

      /// 👉 Trigger delete
      onDismissed: (_) => onDelete(),

      /// 👉 Background UI while swiping
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Iconsax.trash,
          color: Colors.white,
          size: 24,
        ),
      ),

      /// 👉 MAIN TILE
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Row(
              children: [
                /// 🔥 CATEGORY ICON
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIcon(transaction.category),
                    color: categoryColor,
                  ),
                ),

                const SizedBox(width: 14),

                /// 🔥 TITLE + DATE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.note.isNotEmpty
                            ? transaction.note
                            : transaction.category.name.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        DateFormatter.formatDate(transaction.date),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔥 AMOUNT
                Text(
                  '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 CATEGORY ICON MAPPER
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
}