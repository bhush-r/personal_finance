import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.receipt, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final txn = transactions[index];
        final isIncome = txn.type.name == 'income';
        final color = isIncome ? AppColors.income : AppColors.expense;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Iconsax.arrow_down_2 : Iconsax.arrow_up_2,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            txn.category.name.replaceFirst(
              txn.category.name[0],
              txn.category.name[0].toUpperCase(),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(DateFormatter.formatDate(txn.date)),
          trailing: Text(
            '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(txn.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }
}