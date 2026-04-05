import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/add_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/get_goals.dart';
import '../../domain/usecases/update_goal.dart';
import 'goal_state.dart';

class GoalCubit extends Cubit<GoalState> {
  final GetGoals getGoals;
  final AddGoal addGoal;
  final UpdateGoal updateGoal;
  final DeleteGoal deleteGoal;

  GoalCubit({
    required this.getGoals,
    required this.addGoal,
    required this.updateGoal,
    required this.deleteGoal,
  }) : super(const GoalInitial());

  /// LOAD GOALS
  Future<void> loadGoals() async {
    emit(const GoalLoading());

    final result = await getGoals(NoParams());

    result.fold(
          (failure) => emit(GoalError(message: failure.message)),
          (goals) => emit(GoalLoaded(goals: goals)),
    );
  }

  /// CREATE GOAL
  Future<void> createGoal(Goal goal) async {
    final result = await addGoal(AddGoalParams(goal: goal));

    result.fold(
          (failure) => emit(GoalError(message: failure.message)),
          (_) {
        // Don't use async here, use loadGoals() directly
        loadGoals();
      },
    );
  }

  /// ADD PROGRESS - 🔥 FIXED
  Future<void> addProgress(Goal goal, double amount) async {
    final updated = goal.copyWith(
      currentAmount:
      (goal.currentAmount + amount).clamp(0.0, goal.targetAmount),
    );

    final result = await updateGoal(UpdateGoalParams(goal: updated));

    result.fold(
          (failure) => emit(GoalError(message: failure.message)),
          (_) {
        // Properly refresh UI
        loadGoals();
      },
    );
  }

  /// NO-SPEND STREAK
  Future<void> incrementNoSpendStreak(Goal goal) async {
    final updated = goal.copyWith(
      noSpendDays: (goal.noSpendDays ?? 0) + 1,
    );

    final result = await updateGoal(UpdateGoalParams(goal: updated));

    result.fold(
          (failure) => emit(GoalError(message: failure.message)),
          (_) {
        loadGoals();
      },
    );
  }

  /// DELETE GOAL
  Future<void> removeGoal(String id) async {
    final result = await deleteGoal(DeleteGoalParams(id: id));

    result.fold(
          (failure) => emit(GoalError(message: failure.message)),
          (_) {
        loadGoals();
      },
    );
  }
}