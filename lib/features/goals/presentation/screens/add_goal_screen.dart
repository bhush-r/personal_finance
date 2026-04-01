import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/goal.dart';
import '../cubit/goal_cubit.dart';
import '../../../../shared/widgets/app_button.dart';

class AddGoalScreen extends StatefulWidget {
  final GoalType goalType;
  const AddGoalScreen({super.key, required this.goalType});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  late GoalType _type;
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  DateTime? _deadline;
  String? _selectedCategory;

  static const _categories = [
    'food', 'transport', 'shopping', 'health',
    'bills', 'entertainment', 'other',
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.goalType;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final target = double.tryParse(_targetCtrl.text);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    if ((target == null || target <= 0) && _type != GoalType.noSpend) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid target')));
      return;
    }

    final goal = Goal(
      id: '',
      title: title,
      type: _type,
      targetAmount: _type == GoalType.noSpend
          ? (target ?? 30).toDouble()
          : target!,
      currentAmount: 0,
      deadline: _deadline,
      streakDays: 0,
      category: _selectedCategory,
    );

    context.read<GoalCubit>().createGoal(goal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _titleForType(_type),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: _type == GoalType.noSpend
                  ? 'Target days (e.g. 30)'
                  : 'Target amount (₹)',
            ),
          ),
          if (_type != GoalType.noSpend) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(_deadline == null
                  ? 'Set deadline (optional)'
                  : 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
          ],
          if (_type == GoalType.noSpend || _type == GoalType.budgetCap) ...[
            const SizedBox(height: 12),
            Text('Category',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat[0].toUpperCase() + cat.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          AppButton(label: 'Create Goal', onPressed: _submit),
        ],
      ),
    );
  }

  String _titleForType(GoalType type) {
    switch (type) {
      case GoalType.savings:
        return '💰 New Savings Goal';
      case GoalType.noSpend:
        return '🔥 No-Spend Challenge';
      case GoalType.budgetCap:
        return '📊 Budget Cap';
    }
  }
}
