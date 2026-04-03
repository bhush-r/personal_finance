import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource localDataSource;

  GoalRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    try {
      final models = await localDataSource.getGoals();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Goal>> addGoal(Goal goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      await localDataSource.saveGoal(model);
      return Right(goal);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      await localDataSource.updateGoal(model);
      return Right(goal);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteGoal(String id) async {
    try {
      await localDataSource.deleteGoal(id);
      return const Right(true);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}