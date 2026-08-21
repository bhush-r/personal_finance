import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../../../../shared/widgets/category_selector.dart';
import '../../../../shared/widgets/enhanced_text_field.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late String _category;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _date;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? TransactionType.expense;
    _category = widget.transaction?.category ?? 'Food';
    _amountCtrl = TextEditingController(
      text: widget.transaction != null ? widget.transaction!.amount.toString() : '',
    );
    _noteCtrl = TextEditingController(text: widget.transaction?.note ?? '');
    _date = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) return;

    final txn = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      type: _type, // Ensure selected _type (income or expense) is assigned
      category: _category,
      date: _date,
      note: _noteCtrl.text,
    );

    if (isEditing) {
      context.read<TransactionBloc>().add(UpdateTransactionEvent(txn));
    } else {
      context.read<TransactionBloc>().add(AddTransactionEvent(txn));
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Transaction" : "Add Transaction")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Transaction Type Switcher (Income vs Expense)
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward, color: Colors.red),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward, color: Colors.green),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> selection) {
                  setState(() {
                    _type = selection.first;
                    // Reset category depending on selected type
                    _category = _type == TransactionType.income ? 'Salary' : 'Food';
                  });
                },
              ),
              const SizedBox(height: 20),

              // 2. Amount Input
              EnhancedTextField(
                controller: _amountCtrl,
                label: "Amount",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // 3. Category Selector
              CategorySelector(
                selectedCategory: _category,
                onSelected: (selected) => setState(() => _category = selected),
              ),
              const SizedBox(height: 16),

              // 4. Note Input
              EnhancedTextField(
                controller: _noteCtrl,
                label: "Note",
              ),
              const SizedBox(height: 24),

              // 5. Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: Text(isEditing ? "Update Transaction" : "Save Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}