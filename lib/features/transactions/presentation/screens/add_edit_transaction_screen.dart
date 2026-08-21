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

  const AddEditTransactionScreen({
    super.key,
    this.transaction,
  });

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends State<AddEditTransactionScreen> {
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

    _category = widget.transaction?.category ??
        (_type == TransactionType.income ? 'Salary' : 'Food');

    _amountCtrl = TextEditingController(
      text: widget.transaction != null
          ? widget.transaction!.amount.toString()
          : '',
    );

    _noteCtrl = TextEditingController(
      text: widget.transaction?.note ?? '',
    );

    _date = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
        ),
      );
      return;
    }

    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: _noteCtrl.text.trim(),
    );

    if (isEditing) {
      context.read<TransactionBloc>().add(
        UpdateTransactionEvent(transaction),
      );
    } else {
      context.read<TransactionBloc>().add(
        AddTransactionEvent(transaction),
      );
    }

    context.pop();
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      _date = selectedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              FocusScope.of(context).unfocus();
              context.pop();
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TRANSACTION TYPE
                  Text(
                    'Transaction Type',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment<TransactionType>(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment<TransactionType>(
                        value: TransactionType.income,
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: <TransactionType>{_type},
                    onSelectionChanged: (Set<TransactionType> selection) {
                      if (selection.isEmpty) return;
                      setState(() {
                        _type = selection.first;
                        _category = _type == TransactionType.income
                            ? 'Salary'
                            : 'Food';
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // AMOUNT
                  EnhancedTextField(
                    controller: _amountCtrl,
                    label: 'Amount',
                    hint: 'Enter amount',
                    prefixIcon: Icons.currency_rupee,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null) {
                        return 'Please enter a valid amount';
                      }
                      if (amount <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // CATEGORY
                  CategorySelector(
                    selectedCategory: _category,
                    onSelected: (selectedCategory) {
                      setState(() {
                        _category = selectedCategory;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // DATE
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      child: Text(
                        '${_date.day.toString().padLeft(2, '0')}/'
                            '${_date.month.toString().padLeft(2, '0')}/'
                            '${_date.year}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NOTE
                  EnhancedTextField(
                    controller: _noteCtrl,
                    label: 'Note',
                    hint: 'Add a note (optional)',
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),

                  // SUBMIT
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update Transaction' : 'Save Transaction',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}