import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';

import '../cubit/goal_cubit.dart';
import '../cubit/goal_state.dart';
import '../../domain/entities/goal.dart';

import '../widgets/goal_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: const Text("Goals"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      /// ✅ FIXED NAVIGATION
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/goals/add',
          extra: GoalType.savings,
        ),
        backgroundColor: Colors.black,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text("Add Goal"),
      ),

      body: BlocBuilder<GoalCubit, GoalState>(
        builder: (context, state) {

          if (state is GoalLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GoalLoaded) {
            if (state.goals.isEmpty) {
              return _empty();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.goals.length,
              itemBuilder: (_, i) {
                final goal = state.goals[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: GoalCard(
                    goal: goal,

                    onAddProgress: () {
                      context.read<GoalCubit>().addProgress(goal, 100);
                    },

                    onDelete: () {
                      context.read<GoalCubit>().removeGoal(goal.id);
                    },
                  ),
                );
              },
            );
          }

          if (state is GoalError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.flag, size: 60),
          SizedBox(height: 10),
          Text("No Goals Yet"),
        ],
      ),
    );
  }
}