import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/goal.dart';
import '../cubit/goal_cubit.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/enhanced_text_field.dart';

class AddGoalScreen extends StatefulWidget {
  final GoalType goalType;

  const AddGoalScreen({super.key, required this.goalType});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  void _submit() {
    final goal = Goal(
      id: const Uuid().v4(),
      name: _nameCtrl.text,
      type: widget.goalType,
      targetAmount: double.tryParse(_amountCtrl.text) ?? 0,
      currentAmount: 0,
      createdDate: DateTime.now(),
    );

    context.read<GoalCubit>().createGoal(goal);

    /// ✅ FIXED
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: const Text("Add Goal"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  EnhancedTextField(
                    controller: _nameCtrl,
                    label: "Goal Name",
                  ),
                  const SizedBox(height: 16),
                  EnhancedTextField(
                    controller: _amountCtrl,
                    label: "Target Amount",
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),


            AppButton(
              label: "Create Goal",
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}