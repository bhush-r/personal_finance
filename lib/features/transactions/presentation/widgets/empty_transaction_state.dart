import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmptyTransactionState extends StatelessWidget {
  const EmptyTransactionState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Iconsax.receipt_1,
                size: 50,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'No Transactions Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Start tracking your income and expenses\nin a smarter way 💸',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}