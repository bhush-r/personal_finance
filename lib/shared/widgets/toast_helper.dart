import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ToastHelper {
  static SnackBar _buildSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
    );
  }

  static void showSuccess(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.green.shade600,
        icon: Iconsax.tick_circle,
        duration: duration,
      ),
    );
  }

  static void showError(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.red.shade600,
        icon: Iconsax.close_circle,
        duration: duration,
      ),
    );
  }

  static void showInfo(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.blue.shade600,
        icon: Iconsax.info_circle,
        duration: duration,
      ),
    );
  }

  static void showWarning(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.orange.shade600,
        icon: Iconsax.warning_2,
        duration: duration,
      ),
    );
  }

  static void showCustom(
      BuildContext context, {
        required String message,
        required Color backgroundColor,
        required IconData icon,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        duration: duration,
      ),
    );
  }
}