import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? lottieAsset;
  final IconData? icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.lottieAsset,
    this.icon,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              FadeInDown(
                child: Lottie.asset(
                  lottieAsset!,
                  height: 200,
                  repeat: true,
                ),
              )
            else if (icon != null)
              FadeInDown(
                child: Icon(
                  icon,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
              ),

            const SizedBox(height: 24),

            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 32),

              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}