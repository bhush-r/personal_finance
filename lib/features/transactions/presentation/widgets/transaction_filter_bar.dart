// lib/features/transactions/presentation/widgets/transaction_filter_bar.dart
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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
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
          ),
          onChanged: _onSearchChanged, // Debounced call
        ),
        const SizedBox(height: 12),
        _buildTypeFilters(),
      ],
    );
  }

  Widget _buildTypeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', widget.selectedType == null, () => widget.onTypeChanged(null)),
          const SizedBox(width: 8),
          ...TransactionType.values.map((type) {
            final isSelected = widget.selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                type.name.toUpperCase(),
                isSelected,
                    () => widget.onTypeChanged(isSelected ? null : type),
                color: type == TransactionType.income ? AppColors.income : AppColors.expense,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.primary) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}