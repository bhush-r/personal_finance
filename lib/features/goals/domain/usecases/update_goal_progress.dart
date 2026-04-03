import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class UpdateGoalProgress implements UseCase<Goal, UpdateGoalProgressParams> {
  final GoalRepository repository;
  UpdateGoalProgress(this.repository);

  @override
  Future<Either<Failure, Goal>> call(UpdateGoalProgressParams params) {
    final goal = params.goal;
    final Goal updated;

    if (goal.type == GoalType.noSpend) {
      // For no-spend challenges, increment streakDays (no upper clamp)
      updated = goal.copyWith(
        streakDays: goal.streakDays + params.amountToAdd.toInt(),
        currentAmount: goal.streakDays + params.amountToAdd,
      );
    } else {
      updated = goal.copyWith(
        currentAmount: (goal.currentAmount + params.amountToAdd)
            .clamp(0.0, goal.targetAmount),
      );
    }
    return repository.updateGoal(updated);
  }
}

class UpdateGoalProgressParams extends Equatable {
  final Goal goal;
  final double amountToAdd;

  const UpdateGoalProgressParams({
    required this.goal,
    required this.amountToAdd,
  });

  @override
  List<Object?> get props => [goal, amountToAdd];
}