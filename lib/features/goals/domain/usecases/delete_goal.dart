import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/goal_repository.dart';

class DeleteGoal implements UseCase<void, DeleteGoalParams> {
  final GoalRepository repository;

  DeleteGoal(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteGoalParams params) {
    return repository.deleteGoal(params.id);
  }
}

class DeleteGoalParams extends Equatable {
  final String id;

  const DeleteGoalParams({required this.id});

  @override
  List<Object?> get props => [id];
}