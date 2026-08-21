import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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
    final progress = goal.getProgress().clamp(0.0, 1.0);

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            if (goal.description != null &&
                goal.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                goal.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],

            const SizedBox(height: 16),

            FDeterminateProgress(
              value: progress,
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(goal.currentAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  CurrencyFormatter.format(goal.targetAmount),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FButton(
                    prefix: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                    onPress: onAddProgress,
                    child: const Text('Add Progress'),
                  ),
                ),

                if (onDelete != null) ...[
                  const SizedBox(width: 8),

                  FButton.icon(
                    variant: FButtonVariant.destructive,
                    onPress: onDelete,
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}