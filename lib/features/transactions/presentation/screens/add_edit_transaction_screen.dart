import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/entities/transaction.dart';
import '../../../../injection_container.dart';
import '../viewmodels/transactions_view_model.dart';

import '../../../../shared/widgets/enhanced_text_field.dart';
import '../../../../shared/widgets/category_selector.dart';
import '../../../../shared/widgets/validation_helper.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen>
    with TickerProviderStateMixin {
  late TransactionType _type;
  late String _category;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _date;

  late AnimationController _slideController;
  late AnimationController _successController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    _type = widget.transaction?.type ?? TransactionType.expense;
    _category = widget.transaction?.category ?? 'Food';
    _amountCtrl = TextEditingController(
        text: widget.transaction?.amount.toString() ?? '');
    _noteCtrl = TextEditingController(text: widget.transaction?.note ?? '');
    _date = widget.transaction?.date ?? DateTime.now();

    // Initialize animations
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );

    // Start entrance animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _successController.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    if (amount <= 0) {
      HapticFeedback.mediumImpact();
      _showErrorSnackBar("Please enter a valid amount");
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final txn = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: _noteCtrl.text,
    );

    final error = await sl<TransactionsViewModel>().save(
      txn,
      isEditing: isEditing,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _isSubmitting = false);
      _showErrorSnackBar(error);
      return;
    }

    // Play success animation
    await _playSuccessAnimation();

    // Small delay before navigation
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      HapticFeedback.lightImpact();
      context.pop();
    }
  }

  Future<void> _playSuccessAnimation() async {
    await _successController.forward();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.warning_2, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(isEditing ? "Edit Transaction" : "Add Transaction"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTypeToggle(),
                      const SizedBox(height: 20),
                      _buildFormCard(),
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Success overlay
          if (_isSubmitting)
            FadeTransition(
              opacity: _successController,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _successController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.tick_circle,
                        color: Colors.green,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: TransactionType.values.map((type) {
          final selected = _type == type;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _type = type);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                    colors: type == TransactionType.income
                        ? [Colors.green, Colors.green.shade700]
                        : [Colors.red, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: (type == TransactionType.income
                          ? Colors.green
                          : Colors.red)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  type.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          EnhancedTextField(
            controller: _amountCtrl,
            label: "Amount",
            hintText: "0.00",
            prefixIcon: Iconsax.wallet,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            validator: ValidationHelper.validateAmount,
          ),
          const SizedBox(height: 20),
          CategorySelector(
            selectedCategory: _category,
            onSelected: (c) {
              HapticFeedback.selectionClick();
              setState(() => _category = c);
            },
          ),
          const SizedBox(height: 20),
          _buildDatePicker(),
          const SizedBox(height: 20),
          EnhancedTextField(
            controller: _noteCtrl,
            label: "Note",
            hintText: "Optional note...",
            prefixIcon: Iconsax.note,
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Iconsax.calendar, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_date.day}/${_date.month}/${_date.year}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.edit,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: _isSubmitting
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : Text(
        isEditing ? "Update Transaction" : "Save Transaction",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
