import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource localDataSource;

  GoalRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    try {
      final goals = await localDataSource.getGoals();
      return Right(goals);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Goal>> addGoal(Goal goal) async {
    try {
      final result = await localDataSource.addGoal(goal);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    try {
      final result = await localDataSource.updateGoal(goal);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) async {
    try {
      await localDataSource.deleteGoal(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}