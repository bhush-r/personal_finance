import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

import '../../../../shared/widgets/app_button.dart';
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

class _AddEditTransactionScreenState
    extends State<AddEditTransactionScreen> {
  late TransactionType _type;
  late TransactionCategory _category;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _date;

  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? TransactionType.expense;
    _category =
        widget.transaction?.category ?? TransactionCategory.food;
    _amountCtrl = TextEditingController(
        text: widget.transaction?.amount.toString() ?? '');
    _noteCtrl =
        TextEditingController(text: widget.transaction?.note ?? '');
    _date = widget.transaction?.date ?? DateTime.now();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    final txn = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: _noteCtrl.text,
    );

    if (isEditing) {
      context.read<TransactionBloc>().add(
        UpdateTransactionEvent(transaction: txn),
      );
    } else {
      context.read<TransactionBloc>().add(
        AddTransactionEvent(transaction: txn),
      );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: Text(isEditing ? "Edit" : "Add Transaction"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// 🔥 TYPE SWITCH
              _buildTypeToggle(),

              const SizedBox(height: 20),

              /// 🔥 CARD FORM
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    EnhancedTextField(
                      controller: _amountCtrl,
                      label: "Amount",
                      hint: "0.00",
                      icon: Iconsax.wallet,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: ValidationHelper.validateAmount,
                    ),

                    const SizedBox(height: 16),

                    CategorySelector(
                      selected: _category,
                      onSelected: (c) =>
                          setState(() => _category = c),
                    ),

                    const SizedBox(height: 16),

                    _buildDatePicker(),

                    const SizedBox(height: 16),

                    EnhancedTextField(
                      controller: _noteCtrl,
                      label: "Note",
                      hint: "Optional note...",
                      icon: Iconsax.note,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              AppButton(
                label: isEditing ? "Update" : "Save",
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: TransactionType.values.map((type) {
          final selected = _type == type;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? (type == TransactionType.income
                      ? Colors.green
                      : Colors.red)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Iconsax.calendar),
      title: Text(
        "${_date.day}/${_date.month}/${_date.year}",
      ),
      trailing: const Icon(Iconsax.arrow_right_3),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (picked != null) setState(() => _date = picked);
      },
    );
  }
}