import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../datasources/goal_remote_datasource.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource localDataSource;
  final GoalRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GoalRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    try {
      final localGoals = await localDataSource.getGoals();

      if (await networkInfo.isConnected) {
        try {
          final remoteGoals = await remoteDataSource.getGoals();
          // Optional: Sync remote to local
        } catch (_) {}
      }

      return Right(localGoals);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Goal>> addGoal(Goal goal) async {
    try {
      final result = await localDataSource.addGoal(goal);

      if (await networkInfo.isConnected) {
        await remoteDataSource.uploadGoal(goal);
      }

      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    try {
      final result = await localDataSource.updateGoal(goal);

      if (await networkInfo.isConnected) {
        await remoteDataSource.uploadGoal(goal);
      }

      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) async {
    try {
      await localDataSource.deleteGoal(id);

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteGoal(id);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
