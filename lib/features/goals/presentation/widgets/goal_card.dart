import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/goal.dart';
import '../../../../core/utils/currency_formatter.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onAddProgress;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onAddProgress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.getProgress();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.04),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),

              /// DELETE
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Iconsax.trash, color: Colors.red),
                ),
            ],
          ),

          if (goal.description != null) ...[
            const SizedBox(height: 6),
            Text(
              goal.description!,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],

          const SizedBox(height: 16),

          /// 🔥 PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                progress < 0.5
                    ? Colors.green
                    : progress < 0.8
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔥 AMOUNTS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${CurrencyFormatter.format(goal.currentAmount)}",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                "₹${CurrencyFormatter.format(goal.targetAmount)}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔥 BUTTON
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onAddProgress,
              icon: const Icon(Iconsax.add, size: 16),
              label: const Text("Add"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}