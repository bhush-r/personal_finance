import 'package:flutter/material.dart';

class GoalProgressBar extends StatelessWidget {
  final double progress;

  const GoalProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Colors.green,
                  Colors.orange,
                  Colors.red,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}