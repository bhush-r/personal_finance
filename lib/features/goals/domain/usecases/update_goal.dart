import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class UpdateGoal implements UseCase<Goal, UpdateGoalParams> {
  final GoalRepository repository;

  UpdateGoal(this.repository);

  @override
  Future<Either<Failure, Goal>> call(UpdateGoalParams params) {
    return repository.updateGoal(params.goal);
  }
}

class UpdateGoalParams extends Equatable {
  final Goal goal;

  const UpdateGoalParams({required this.goal});

  @override
  List<Object?> get props => [goal];
}