import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/get_goals.dart';
import '../../domain/usecases/add_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/update_goal_progress.dart';
import '../../../../core/usecases/usecase.dart';
import 'goal_state.dart';

class GoalCubit extends Cubit<GoalState> {
  final GetGoals getGoals;
  final AddGoal addGoal;
  final DeleteGoal deleteGoal;
  final UpdateGoalProgress updateGoalProgress;

  GoalCubit({
    required this.getGoals,
    required this.addGoal,
    required this.deleteGoal,
    required this.updateGoalProgress,
  }) : super(GoalInitial());

  Future<void> loadGoals() async {
    emit(GoalLoading());
    final result = await getGoals(NoParams());
    result.fold(
      (failure) => emit(GoalError(message: failure.message)),
      (goals) => emit(GoalLoaded(goals: goals)),
    );
  }

  Future<void> createGoal(Goal goal) async {
    final newGoal = goal.copyWith(id: const Uuid().v4());
    final result = await addGoal(AddGoalParams(goal: newGoal));
    result.fold(
      (failure) => emit(GoalError(message: failure.message)),
      (_) => loadGoals(),
    );
  }

  Future<void> removeGoal(String id) async {
    final result = await deleteGoal(DeleteGoalParams(id: id));
    result.fold(
      (failure) => emit(GoalError(message: failure.message)),
      (_) => loadGoals(),
    );
  }

  Future<void> addProgress(Goal goal, double amount) async {
    final result = await updateGoalProgress(
      UpdateGoalProgressParams(goal: goal, amountToAdd: amount),
    );
    result.fold(
      (failure) => emit(GoalError(message: failure.message)),
      (_) => loadGoals(),
    );
  }
}
