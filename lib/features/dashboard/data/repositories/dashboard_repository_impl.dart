import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, FinancialSummary>> getFinancialSummary() async {
    try {
      final models = await localDataSource.getAllTransactions();
      final transactions = models.map((m) => m.toEntity()).toList();
      return Right(FinancialSummary.fromTransactions(transactions));
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}