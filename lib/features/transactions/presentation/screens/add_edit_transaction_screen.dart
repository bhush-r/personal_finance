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
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fade_in_animation.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
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
    _category = widget.transaction?.category ?? TransactionCategory.food;
    _amountCtrl = TextEditingController(
        text: widget.transaction?.amount.toString() ?? '');
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.parse(_amountCtrl.text);

    final txn = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: _noteCtrl.text,
    );

    if (isEditing) {
      context.read<TransactionBloc>().add(UpdateTransactionEvent(transaction: txn));
    } else {
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction: txn));
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: FadeInAnimation(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Income / Expense Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: TransactionType.values.map((type) {
                      final isSelected = _type == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (type == TransactionType.income
                                  ? AppColors.income
                                  : AppColors.expense)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              type == TransactionType.income ? 'Income' : 'Expense',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Amount with validation
                EnhancedTextField(
                  controller: _amountCtrl,
                  label: 'Amount',
                  hint: '0.00',
                  icon: Iconsax.wallet,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: ValidationHelper.validateAmount,
                ),
                const SizedBox(height: 16),

                // Category Picker
                CategorySelector(
                  selected: _category,
                  onSelected: (cat) => setState(() => _category = cat),
                ),
                const SizedBox(height: 16),

                // Date Picker
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Iconsax.calendar),
                    title: Text(
                      '${_date.day}/${_date.month}/${_date.year}',
                    ),
                    trailing: const Icon(Iconsax.arrow_right_3, size: 16),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Note with validation
                EnhancedTextField(
                  controller: _noteCtrl,
                  label: 'Note',
                  hint: 'Add a note (optional)',
                  icon: Iconsax.note,
                  maxLines: 3,
                  minLines: 2,
                  validator: ValidationHelper.validateNote,
                ),
                const SizedBox(height: 32),

                // Submit Button
                AppButton(
                  label: isEditing ? 'Update Transaction' : 'Add Transaction',
                  onPressed: _submit,
                ),

                if (isEditing) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Delete Transaction',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Transaction'),
                          content: const Text(
                            'Are you sure you want to delete this transaction?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<TransactionBloc>().add(
                                  DeleteTransactionEvent(
                                    id: widget.transaction!.id,
                                  ),
                                );
                                Navigator.pop(ctx);
                                context.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    isDestructive: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}