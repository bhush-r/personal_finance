import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/goal.dart';
import '../cubit/goal_cubit.dart';
import '../cubit/goal_state.dart';
import '../widgets/goal_card.dart';
import '../widgets/no_spend_challenge_card.dart';
import 'add_goal_screen.dart';
import '../../../../core/theme/app_colors.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoalCubit>().loadGoals();
  }

  void _showAddGoal(GoalType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<GoalCubit>(),
        child: AddGoalScreen(goalType: type),
      ),
    );
  }

  void _showAddProgressDialog(BuildContext ctx, Goal goal) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add Progress'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Amount to add',
            prefixText: '₹',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                ctx.read<GoalCubit>().addProgress(goal, amount);
              }
              Navigator.pop(dialogCtx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context, List<Goal> goals) {
    final savingsGoals =
    goals.where((g) => g.type == GoalType.savings).toList();
    final noSpendGoals =
    goals.where((g) => g.type == GoalType.noSpend).toList();
    final budgetGoals =
    goals.where((g) => g.type == GoalType.budgetCap).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (savingsGoals.isNotEmpty) ...[
          Text('Savings Goals',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...savingsGoals.map((g) => GoalCard(
            goal: g,
            onAddProgress: () => _showAddProgressDialog(context, g),
          )),
          const SizedBox(height: 16),
        ],
        if (noSpendGoals.isNotEmpty) ...[
          Text('No-Spend Challenges',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...noSpendGoals.map((g) => NoSpendChallengeCard(
            goal: g,
            onIncrementStreak: () =>
                context.read<GoalCubit>().addProgress(g, 1),
            onDelete: () =>
                context.read<GoalCubit>().removeGoal(g.id),
          )),
          const SizedBox(height: 16),
        ],
        if (budgetGoals.isNotEmpty) ...[
          Text('Budget Caps',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...budgetGoals.map((g) => GoalCard(
            goal: g,
            onAddProgress: () => _showAddProgressDialog(context, g),
          )),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Goals & Challenges',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<GoalCubit, GoalState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => context.read<GoalCubit>().loadGoals(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _QuickAddButton(
                        label: '💰 Savings Goal',
                        onTap: () => _showAddGoal(GoalType.savings),
                      ),
                      const SizedBox(width: 8),
                      _QuickAddButton(
                        label: '🔥 No-Spend',
                        onTap: () => _showAddGoal(GoalType.noSpend),
                      ),
                      const SizedBox(width: 8),
                      _QuickAddButton(
                        label: '📊 Budget Cap',
                        onTap: () => _showAddGoal(GoalType.budgetCap),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (state is GoalLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is GoalError)
                    Center(child: Text(state.message))
                  else if (state is GoalLoaded)
                      state.goals.isEmpty
                          ? Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Iconsax.chart,
                                size: 72, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No goals yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap a button above to create your first goal',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                  color: Colors.grey.shade400),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                          : _buildGoalsList(context, state.goals),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}