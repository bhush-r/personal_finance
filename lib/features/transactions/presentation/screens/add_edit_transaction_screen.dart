import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../../../../shared/widgets/validation_helper.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  late TransactionType _type;
  late TransactionCategory _category;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _date;
  int _selectedPayment = 0;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.transaction != null;

  static const _expenseCategories = [
    TransactionCategory.food,
    TransactionCategory.transport,
    TransactionCategory.shopping,
    TransactionCategory.bills,
    TransactionCategory.entertainment,
    TransactionCategory.health,
    TransactionCategory.other,
    TransactionCategory.savings,
  ];

  static const _incomeCategories = [
    TransactionCategory.salary,
    TransactionCategory.savings,
    TransactionCategory.other,
    TransactionCategory.health,
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? TransactionType.expense;
    _category = widget.transaction?.category ??
        (_type == TransactionType.expense ? TransactionCategory.food : TransactionCategory.salary);
    _amountCtrl = TextEditingController(text: widget.transaction?.amount.toStringAsFixed(2) ?? '23.00');
    _noteCtrl = TextEditingController(text: widget.transaction?.note ?? '');
    _date = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      HapticFeedback.mediumImpact();
      _showSnackBar('Please enter a valid amount');
      return;
    }

    setState(() => _isSubmitting = true);

    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: _noteCtrl.text.trim(),
    );

    if (isEditing) {
      context.read<TransactionBloc>().add(UpdateTransactionEvent(transaction: transaction));
    } else {
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction: transaction));
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.expense ? _expenseCategories : _incomeCategories;

    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D14),
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 58,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E82F7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    isEditing ? 'Update Transaction' : 'Add Transaction',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
          children: [
            _buildTypeSwitcher(),
            const SizedBox(height: 14),
            _buildAmountCard(),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = _category == category;
                final palette = _categoryPalette(category);

                return GestureDetector(
                  onTap: () => setState(() => _category = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101722),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? const Color(0xFF3E82F7) : Colors.transparent,
                        width: 1.4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: palette.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_categoryIcon(category), color: palette, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _categoryLabel(category),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _darkInputDecoration('Add a note...'),
              maxLines: 1,
            ),
            const SizedBox(height: 20),
            const Text(
              'Date',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A222D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.calendar, color: Color(0xFF94A0B4), size: 18),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_date),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Method',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _paymentChip(0, 'Cash', Iconsax.wallet_2),
                const SizedBox(width: 10),
                _paymentChip(1, 'Card', Iconsax.card),
                const SizedBox(width: 10),
                _paymentChip(2, 'Bank', Iconsax.bank),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF121925),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _typeTab(TransactionType.expense, 'Expense'),
          _typeTab(TransactionType.income, 'Income'),
        ],
      ),
    );
  }

  Widget _typeTab(TransactionType type, String label) {
    final selected = _type == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3E82F7) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF95A0B4),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final value = double.tryParse(_amountCtrl.text.trim());
    final formattedAmount = value == null ? _amountCtrl.text.trim() : value.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101722),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(color: Color(0xFF8E99AE), fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 42,
            ),
            validator: ValidationHelper.validateAmount,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixText: '\$',
              prefixStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 42,
              ),
              hintText: formattedAmount.isEmpty ? '0.00' : formattedAmount,
              hintStyle: const TextStyle(color: Color(0xFF5F6878), fontSize: 42, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(int index, String label, IconData icon) {
    final selected = _selectedPayment == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPayment = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3E82F7) : const Color(0xFF1A222D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _darkInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1A222D),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF728099)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3E82F7)),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  IconData _categoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Iconsax.cup;
      case TransactionCategory.transport:
        return Iconsax.bus;
      case TransactionCategory.shopping:
        return Iconsax.bag;
      case TransactionCategory.health:
        return Iconsax.heart;
      case TransactionCategory.bills:
        return Iconsax.receipt_text;
      case TransactionCategory.salary:
        return Iconsax.money_recive;
      case TransactionCategory.savings:
        return Iconsax.save_2;
      case TransactionCategory.entertainment:
        return Iconsax.game;
      case TransactionCategory.other:
        return Iconsax.more;
    }
  }

  String _categoryLabel(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Food';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.health:
        return 'Health';
      case TransactionCategory.bills:
        return 'Bills';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.savings:
        return 'Savings';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  Color _categoryPalette(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return const Color(0xFFF5B322);
      case TransactionCategory.transport:
        return const Color(0xFF4E89FF);
      case TransactionCategory.shopping:
        return const Color(0xFFA855F7);
      case TransactionCategory.health:
        return const Color(0xFF21C98D);
      case TransactionCategory.bills:
        return const Color(0xFF8BEC3D);
      case TransactionCategory.salary:
        return const Color(0xFF21C98D);
      case TransactionCategory.savings:
        return const Color(0xFF3E82F7);
      case TransactionCategory.entertainment:
        return const Color(0xFFF76CC7);
      case TransactionCategory.other:
        return const Color(0xFF16BAE2);
    }
  }
}
