import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/insight.dart';
import '../../domain/repositories/insights_repository.dart';
import '../datasources/insights_local_datasource.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  final InsightsLocalDataSource localDataSource;

  InsightsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Insight>> getInsights() async {
    try {
      final insights = await localDataSource.getInsights();
      return Right(insights);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}