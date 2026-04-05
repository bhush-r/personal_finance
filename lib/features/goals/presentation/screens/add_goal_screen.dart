import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/goal.dart';
import '../cubit/goal_cubit.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/amount_input_field.dart';

class AddGoalScreen extends StatefulWidget {
  final GoalType goalType;

  const AddGoalScreen({super.key, required this.goalType});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _descriptionCtrl;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _amountCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal name')),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0 && widget.goalType != GoalType.noSpend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target amount')),
      );
      return;
    }

    final goal = Goal(
      id: const Uuid().v4(),
      name: _nameCtrl.text,
      type: widget.goalType,
      targetAmount: amount,
      currentAmount: 0,
      createdDate: DateTime.now(),
      deadline: _deadline,
      description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
      noSpendDays: widget.goalType == GoalType.noSpend ? 0 : null,
    );

    context.read<GoalCubit>().createGoal(goal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNoSpend = widget.goalType == GoalType.noSpend;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.goalType == GoalType.savings
              ? 'New Savings Goal'
              : widget.goalType == GoalType.noSpend
              ? 'New No-Spend Challenge'
              : 'New Budget Cap',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g., Summer Vacation',
              ),
            ),
            const SizedBox(height: 16),
            if (!isNoSpend)
              AmountInputField(
                controller: _amountCtrl,
                label: 'Target Amount',
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No-Spend Challenge',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your no-spend streak. Try to go as many days as possible without spending!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Why this goal matters to you',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deadline (Optional)'),
              trailing: _deadline == null
                  ? const Icon(Icons.calendar_today)
                  : Text(
                '${_deadline?.day}/${_deadline?.month}/${_deadline?.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _deadline = picked);
                }
              },
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Create Goal',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}