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
import '../../../../shared/widgets/loading_shimmer_skeleton.dart';
import '../../../../shared/widgets/fade_in_animation.dart';
import '../../../../shared/dialogs/delete_confirmation_dialog.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Use WidgetsBinding to delay Cubit access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GoalCubit>().loadGoals();
      }
    });
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
                Navigator.pop(dialogCtx);
              } else {
                ScaffoldMessenger.of(dialogCtx).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Build goals list grouped by type
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
        // Savings Goals Section
        if (savingsGoals.isNotEmpty) ...[
          Text(
            'Savings Goals',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...savingsGoals.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FadeInAnimation(
                child: GoalCard(
                  goal: e.value,
                  onAddProgress: () =>
                      _showAddProgressDialog(context, e.value),
                  onDelete: () {
                    showDeleteConfirmation(
                      context: context,
                      title: 'Delete Goal',
                      message:
                      'Are you sure you want to delete this savings goal?',
                      itemName: e.value.name,
                      onConfirm: () =>
                          context.read<GoalCubit>().removeGoal(e.value.id),
                    );
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // No-Spend Challenges Section
        if (noSpendGoals.isNotEmpty) ...[
          Text(
            'No-Spend Challenges',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...noSpendGoals.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FadeInAnimation(
                child: NoSpendChallengeCard(
                  goal: e.value,
                  onIncrementStreak: () =>
                      context.read<GoalCubit>().incrementNoSpendStreak(e.value),
                  onDelete: () {
                    showDeleteConfirmation(
                      context: context,
                      title: 'Delete Challenge',
                      message:
                      'Are you sure you want to delete this no-spend challenge?',
                      itemName: e.value.name,
                      onConfirm: () =>
                          context.read<GoalCubit>().removeGoal(e.value.id),
                    );
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Budget Caps Section
        if (budgetGoals.isNotEmpty) ...[
          Text(
            'Budget Caps',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...budgetGoals.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FadeInAnimation(
                child: GoalCard(
                  goal: e.value,
                  onAddProgress: () =>
                      _showAddProgressDialog(context, e.value),
                  onDelete: () {
                    showDeleteConfirmation(
                      context: context,
                      title: 'Delete Budget Cap',
                      message:
                      'Are you sure you want to delete this budget cap?',
                      itemName: e.value.name,
                      onConfirm: () =>
                          context.read<GoalCubit>().removeGoal(e.value.id),
                    );
                  },
                ),
              ),
            );
          }),
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
      body: BlocListener<GoalCubit, GoalState>(
        listener: (context, state) {
          if (state is GoalOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          if (state is GoalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<GoalCubit, GoalState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<GoalCubit>().loadGoals(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Add Buttons
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

                    // Content based on state
                    if (state is GoalLoading)
                      const GoalsLoadingSkeleton()
                    else if (state is GoalError)
                      Center(
                        child: FadeInAnimation(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.warning_2,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(state.message),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<GoalCubit>().loadGoals();
                                },
                                icon: const Icon(Iconsax.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (state is GoalLoaded)
                        state.goals.isEmpty
                            ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(
                                Iconsax.chart,
                                size: 72,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No goals yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                    color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap a button above to create your first goal',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                    color:
                                    Colors.grey.shade400),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                            : _buildGoalsList(context, state.goals),

                    // Bottom spacing
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Quick Add Button Widget
class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.onTap,
  });

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