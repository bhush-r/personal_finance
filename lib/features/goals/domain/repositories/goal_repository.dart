import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/goal.dart';

abstract class GoalRepository {
  Future<Either<Failure, List<Goal>>> getGoals();
  Future<Either<Failure, Goal>> addGoal(Goal goal);
  Future<Either<Failure, Goal>> updateGoal(Goal goal);
  Future<Either<Failure, void>> deleteGoal(String id);
}