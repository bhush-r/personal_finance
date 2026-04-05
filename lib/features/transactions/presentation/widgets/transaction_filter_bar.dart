import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/transaction.dart';
import '../../../../core/theme/app_colors.dart';

class TransactionFilterBar extends StatefulWidget {
  final TransactionType? selectedType;
  final String searchQuery;
  final Function(TransactionType?) onTypeChanged;
  final Function(String) onSearchChanged;

  const TransactionFilterBar({
    super.key,
    this.selectedType,
    required this.searchQuery,
    required this.onTypeChanged,
    required this.onSearchChanged,
  });

  @override
  State<TransactionFilterBar> createState() => _TransactionFilterBarState();
}

class _TransactionFilterBarState extends State<TransactionFilterBar> {
  late TextEditingController _searchCtrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🔥 MODERN SEARCH BAR
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.04),
              )
            ],
          ),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Iconsax.search_normal),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Iconsax.close_circle),
                onPressed: () {
                  _searchCtrl.clear();
                  widget.onSearchChanged('');
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        const SizedBox(height: 14),

        /// 🔥 FILTER CHIPS
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildChip('All', widget.selectedType == null, () {
                widget.onTypeChanged(null);
              }),
              const SizedBox(width: 8),

              ...TransactionType.values.map((type) {
                final isSelected = widget.selectedType == type;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildChip(
                    type.name.toUpperCase(),
                    isSelected,
                        () => widget.onTypeChanged(isSelected ? null : type),
                    color: type == TransactionType.income
                        ? AppColors.income
                        : AppColors.expense,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
      String label,
      bool selected,
      VoidCallback onTap, {
        Color? color,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? (color ?? AppColors.primary)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}