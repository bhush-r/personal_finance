import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<String> _defaultCategories = [
    'Food',
    'Shopping',
    'Junk Food',
    'Street Food',
    'Daily Need',
    'Transport',
    'Bills',
    'Salary',
  ];

  final TextEditingController _customCategoryCtrl = TextEditingController();

  @override
  void dispose() {
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  void _showAddCustomCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Category'),
        content: TextField(
          controller: _customCategoryCtrl,
          decoration: const InputDecoration(
            hintText: 'Enter category name...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = _customCategoryCtrl.text.trim();
              if (val.isNotEmpty) {
                widget.onSelected(val);
                _customCategoryCtrl.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add & Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = {
      ..._defaultCategories,
      if (widget.selectedCategory.isNotEmpty) widget.selectedCategory
    }.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            TextButton.icon(
              onPressed: _showAddCustomCategoryDialog,
              icon: const Icon(Iconsax.add, size: 16),
              label: const Text("Custom"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allCategories.map((cat) {
            final isSelected =
                widget.selectedCategory.toLowerCase() == cat.toLowerCase();
            return ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => widget.onSelected(cat),
            );
          }).toList(),
        ),
      ],
    );
  }
}