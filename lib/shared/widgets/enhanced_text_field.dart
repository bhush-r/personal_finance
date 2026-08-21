import 'package:flutter/material.dart';

class EnhancedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? hint;
  final IconData? icon;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final Widget? suffix;
  final VoidCallback? onChanged;

  const EnhancedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.hint,
    this.icon,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String? displayHint = hintText ?? hint;
    final IconData? displayIcon = prefixIcon ?? icon;
    final bool isMultiline = maxLines > 1;

    final TextInputType effectiveKeyboardType = isMultiline
        ? TextInputType.multiline
        : (keyboardType ?? TextInputType.text);

    final TextInputAction effectiveTextInputAction = isMultiline
        ? TextInputAction.newline
        : TextInputAction.next;

    return TextFormField(
      controller: controller,
      scrollPadding: const EdgeInsets.only(bottom: 24),
      keyboardType: effectiveKeyboardType,
      textInputAction: effectiveTextInputAction,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        labelText: label,
        hintText: displayHint,
        alignLabelWithHint: isMultiline,
        prefixIcon: displayIcon != null
            ? Icon(
          displayIcon,
          size: 20,
        )
            : null,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}