import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GoalProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;

  const GoalProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final color = progress < 0.5
        ? AppColors.income
        : progress < 0.8
        ? AppColors.warning
        : AppColors.expense;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}