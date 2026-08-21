import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDestructive;
  final bool isOutlined;
  final IconData? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.isOutlined = false,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final FButtonVariant variant;

    if (isDestructive) {
      variant = FButtonVariant.destructive;
    } else if (isOutlined) {
      variant = FButtonVariant.outline;
    } else {
      variant = FButtonVariant.primary;
    }

    final button = FButton(
      onPress: isLoading ? null : onPressed,
      variant: variant,
      prefix: icon != null ? Icon(icon, size: 18) : null,
      child: isLoading
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      )
          : Text(label),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}