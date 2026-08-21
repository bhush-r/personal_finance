import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/transaction.dart';
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'junk food':
      case 'street food':
        return Iconsax.cup;
      case 'shopping':
        return Iconsax.bag;
      case 'daily need':
        return Iconsax.box;
      case 'transport':
        return Iconsax.car;
      case 'health':
        return Iconsax.heart;
      case 'bills':
        return Iconsax.receipt;
      case 'salary':
        return Iconsax.money_recive;
      default:
        return Iconsax.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;

    return FTile(
      onPress: onTap,
      prefix: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_getCategoryIcon(transaction.category), size: 20),
      ),
      title: Text(
        transaction.category,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        transaction.note.isNotEmpty
            ? transaction.note
            : DateFormatter.formatDate(transaction.date),
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
          const SizedBox(width: 8),
          FButton.icon(
            child: const Icon(Iconsax.trash, size: 16),
            onPress: onDelete,
            variant: FButtonVariant.ghost,
          ),
        ],
      ),
    );
  }
}