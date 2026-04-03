import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const AmountInputField({
    super.key,
    required this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hintText ?? '0.00',
        prefixText: '₹ ',
        prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.grey,
        ),
        hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.grey.shade300,
          fontWeight: FontWeight.w700,
        ),
        border: InputBorder.none,
        filled: false,
      ),
    );
  }
}