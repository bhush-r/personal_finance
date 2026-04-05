import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const AmountInputField({
    super.key,
    required this.controller,
    this.label = 'Amount',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '₹ ',
        prefixIcon: const Icon(Iconsax.wallet),
        hintText: '0.00',
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator ?? (value) {
        if (value?.isEmpty ?? true) return 'Amount is required';
        final amount = double.tryParse(value!);
        if (amount == null || amount <= 0) return 'Enter a valid amount';
        return null;
      },
    );
  }
}