import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/goal.dart';

class NoSpendChallengeCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onIncrementStreak;
  final VoidCallback onDelete;

  const NoSpendChallengeCard({
    super.key,
    required this.goal,
    required this.onIncrementStreak,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final days = goal.noSpendDays ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade100,
            Colors.orange.shade50,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Iconsax.flash_1, color: Colors.orange),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Text(
                "$days days 🔥",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onIncrementStreak,
                  child: const Text("Add Day"),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Iconsax.trash, color: Colors.red),
              ),
            ],
          )
        ],
      ),
    );
  }
}