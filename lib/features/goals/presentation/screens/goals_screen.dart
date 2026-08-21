import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_finance/features/goals/presentation/screens/saving_streak_screen.dart';

import '../cubit/goal_cubit.dart';
import '../cubit/goal_state.dart';
import '../../domain/entities/goal.dart';

import '../widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({
    super.key,
  });

  @override
  State<GoalsScreen> createState() =>
      _GoalsScreenState();
}

class _GoalsScreenState
    extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 400,
      ),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (!mounted) return;

        context.read<GoalCubit>().loadGoals();

        _animationController.forward();
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F8FA),

      // ---------------------------------------------------------------------
      // APP BAR
      // ---------------------------------------------------------------------

      appBar: AppBar(
        title: const Text(
          'Goals',
        ),

        backgroundColor:
        Colors.transparent,

        elevation: 0,

        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),

            child: FButton.icon(
              onPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                    const SavingStreakScreen(),
                  ),
                );
              },

              child: const Icon(
                Iconsax.flash_1,
              ),
            ),
          ),
        ],
      ),

      // ---------------------------------------------------------------------
      // ADD GOAL
      // ---------------------------------------------------------------------

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () async {
          await context.push(
            '/goals/add',
            extra: GoalType.savings,
          );
        },

        backgroundColor: Colors.black,

        icon: const Icon(
          Iconsax.add,
          color: Colors.white,
        ),

        label: const Text(
          'Add Goal',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      // ---------------------------------------------------------------------
      // BODY
      // ---------------------------------------------------------------------

      body: BlocBuilder<GoalCubit, GoalState>(
        builder: (
            context,
            state,
            ) {
          if (state is GoalLoading) {
            return _buildLoadingState();
          }

          if (state is GoalLoaded) {
            if (state.goals.isEmpty) {
              return _buildEmptyState();
            }

            return _buildGoalsList(
              state.goals,
            );
          }

          if (state is GoalError) {
            return _buildErrorState(
              state.message,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // ===========================================================================
  // LOADING STATE
  // ===========================================================================

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: 3,

      itemBuilder: (
          context,
          index,
          ) {
        return Padding(
          padding:
          const EdgeInsets.only(
            bottom: 14,
          ),

          child: FCard(
            child: const SizedBox(
              height: 160,
              child: _ShimmerBox(),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.all(24),

          child: FCard(
            child: Padding(
              padding:
              const EdgeInsets.all(32),

              child: Column(
                mainAxisSize:
                MainAxisSize.min,

                children: [
                  Container(
                    padding:
                    const EdgeInsets.all(20),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.grey.shade100,

                      shape:
                      BoxShape.circle,
                    ),

                    child: Icon(
                      Iconsax.flag,
                      size: 60,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    'No Goals Yet',

                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    'Start by creating your first financial goal',

                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                      fontSize: 14,
                    ),

                    textAlign:
                    TextAlign.center,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  FButton(
                    onPress: () async {
                      await context.push(
                        '/goals/add',
                        extra:
                        GoalType.savings,
                      );
                    },

                    prefix: const Icon(
                      Iconsax.add,
                      size: 18,
                    ),

                    child: const Text(
                      'Create Goal',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // GOALS LIST
  // ===========================================================================

  Widget _buildGoalsList(
      List<Goal> goals,
      ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: goals.length,

      itemBuilder: (
          context,
          index,
          ) {
        final goal = goals[index];

        return AnimatedListItem(
          index: index,

          child: Padding(
            padding:
            const EdgeInsets.only(
              bottom: 14,
            ),

            child: GoalCard(
              goal: goal,

              onAddProgress: () =>
                  _showProgressDialog(
                    context,
                    goal,
                  ),

              onDelete: () =>
                  _showDeleteConfirmation(
                    context,
                    goal,
                  ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // ERROR STATE
  // ===========================================================================

  Widget _buildErrorState(
      String message,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: FCard(
          child: Padding(
            padding:
            const EdgeInsets.all(24),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [
                Icon(
                  Iconsax.warning_2,
                  size: 60,
                  color:
                  Colors.red.shade400,
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  'Oops! Something went wrong',

                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  message,

                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                  ),

                  textAlign:
                  TextAlign.center,
                ),

                const SizedBox(
                  height: 24,
                ),

                ElevatedButton(
                  onPressed: () {
                    context
                        .read<GoalCubit>()
                        .loadGoals();
                  },

                  child: const Text(
                    'Try Again',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ADD PROGRESS DIALOG
  // ===========================================================================

  void _showProgressDialog(
      BuildContext context,
      Goal goal,
      ) {
    final amountOptions = [
      100,
      500,
      1000,
      2000,
      5000,
      10000,
    ];

    showDialog<void>(
      context: context,

      barrierDismissible: true,

      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),

          title: Text(
            'Add Progress to ${goal.name}',
          ),

          content: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              GridView.count(
                crossAxisCount: 3,

                shrinkWrap: true,

                mainAxisSpacing: 8,

                crossAxisSpacing: 8,

                physics:
                const NeverScrollableScrollPhysics(),

                childAspectRatio: 1.2,

                children: amountOptions
                    .map(
                      (amount) =>
                      _buildAmountButton(
                        context,
                        dialogContext,
                        goal,
                        amount,
                      ),
                )
                    .toList(),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: double.infinity,

                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },

                  child: const Text(
                    'Cancel',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // AMOUNT BUTTON
  // ===========================================================================

  Widget _buildAmountButton(
      BuildContext context,
      BuildContext dialogContext,
      Goal goal,
      int amount,
      ) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () {
          context
              .read<GoalCubit>()
              .addProgress(
            goal,
            amount.toDouble(),
          );

          Navigator.pop(
            dialogContext,
          );

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Iconsax.tick_circle,
                    color: Colors.white,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      'Added ₹$amount to ${goal.name}',
                    ),
                  ),
                ],
              ),

              backgroundColor:
              Colors.green.shade400,

              duration:
              const Duration(seconds: 2),

              behavior:
              SnackBarBehavior.floating,

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),

              margin:
              const EdgeInsets.all(16),
            ),
          );
        },

        borderRadius:
        BorderRadius.circular(12),

        child: Container(
          decoration:
          BoxDecoration(
            color:
            Colors.blue.shade50,

            borderRadius:
            BorderRadius.circular(12),

            border: Border.all(
              color:
              Colors.blue.shade200,
              width: 1.5,
            ),
          ),

          alignment:
          Alignment.center,

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Text(
                '₹',

                style: TextStyle(
                  color:
                  Colors.blue.shade600,
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                '$amount',

                style: const TextStyle(
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DELETE CONFIRMATION
  // ===========================================================================

  void _showDeleteConfirmation(
      BuildContext context,
      Goal goal,
      ) {
    showDialog<void>(
      context: context,

      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),

          title: const Text(
            'Delete Goal?',
          ),

          content: Text(
            "Are you sure you want to delete "
                "'${goal.name}'? This action cannot be undone.",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child: Text(
                'Cancel',
                style: TextStyle(
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                context
                    .read<GoalCubit>()
                    .removeGoal(
                  goal.id,
                );

                Navigator.pop(
                  dialogContext,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(
                          Iconsax.trash,
                          color: Colors.white,
                        ),

                        SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Text(
                            'Goal deleted successfully',
                          ),
                        ),
                      ],
                    ),

                    backgroundColor:
                    Colors.red.shade400,

                    duration:
                    const Duration(
                      seconds: 2,
                    ),

                    behavior:
                    SnackBarBehavior.floating,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),

                    margin:
                    const EdgeInsets.all(16),
                  ),
                );
              },

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red.shade600,

                foregroundColor:
                Colors.white,
              ),

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// STAGGERED ANIMATION HELPER
// =============================================================================

class AnimatedListItem
    extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ),

      duration: Duration(
        milliseconds:
        400 + (index * 100),
      ),

      curve:
      Curves.easeOutCubic,

      builder: (
          context,
          value,
          childWidget,
          ) {
        return Transform.translate(
          offset: Offset(
            0,
            30 * (1 - value),
          ),

          child: Opacity(
            opacity: value,
            child: childWidget,
          ),
        );
      },

      child: child,
    );
  }
}

// =============================================================================
// SHIMMER BOX
// =============================================================================

class _ShimmerBox
    extends StatefulWidget {
  const _ShimmerBox();

  @override
  State<_ShimmerBox> createState() =>
      _ShimmerBoxState();
}

class _ShimmerBoxState
    extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      duration:
      const Duration(
        milliseconds: 1500,
      ),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedBuilder(
      animation: _ctrl,

      builder: (
          context,
          child,
          ) {
        return ShaderMask(
          shaderCallback: (
              bounds,
              ) {
            return LinearGradient(
              begin: Alignment(
                -1.0 -
                    _ctrl.value * 2,
                -0.5,
              ),

              end: Alignment(
                1.0 -
                    _ctrl.value * 2,
                0.5,
              ),

              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],

              stops: const [
                0.0,
                0.5,
                1.0,
              ],
            ).createShader(bounds);
          },

          child: Container(
            color: Colors.white,
          ),
        );
      },
    );
  }
}