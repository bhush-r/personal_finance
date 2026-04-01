import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmptyTransactionState extends StatelessWidget {
  final String message;
  const EmptyTransactionState({
    super.key,
    this.message = 'No transactions found',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.receipt_dissatisfied,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first transaction',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
