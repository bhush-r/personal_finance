import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class AddGoal implements UseCase<Goal, AddGoalParams> {
  final GoalRepository repository;
  AddGoal(this.repository);

  @override
  Future<Either<Failure, Goal>> call(AddGoalParams params) {
    return repository.addGoal(params.goal);
  }
}

class AddGoalParams extends Equatable {
  final Goal goal;
  const AddGoalParams({required this.goal});

  @override
  List<Object?> get props => [goal];
}