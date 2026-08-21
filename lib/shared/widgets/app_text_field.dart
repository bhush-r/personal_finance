import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      scrollPadding: const EdgeInsets.only(top: 80, bottom: 200),
      maxLines: maxLines,
      keyboardType: isMultiline ? TextInputType.multiline : keyboardType,
      textInputAction: isMultiline ? TextInputAction.newline : TextInputAction.next,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        alignLabelWithHint: isMultiline,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}