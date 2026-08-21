import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/entities/transaction.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class TransactionTile extends StatefulWidget {
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
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
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
    final isIncome = widget.transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;

    return Dismissible(
      key: Key(widget.transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Iconsax.trash, color: Colors.white),
      ),
      child: ListTile(
        onTap: widget.onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getCategoryIcon(widget.transaction.category)),
        ),
        title: Text(
          widget.transaction.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          widget.transaction.note.isNotEmpty
              ? widget.transaction.note
              : DateFormatter.formatDate(widget.transaction.date),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(widget.transaction.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ),
    );
  }
}