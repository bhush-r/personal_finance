import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? label;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.label,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: lastDate ?? DateTime.now(),
        );
        if (picked != null) onDateSelected(picked);
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Iconsax.calendar, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label ??
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}