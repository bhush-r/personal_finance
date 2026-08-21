import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/analytics/analytics_service.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AnalyticsService analytics;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.analytics,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final localTransactions = await localDataSource.getTransactions();

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.getTransactions();
        } catch (_) {}
      }

      return Right(localTransactions);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
      Transaction transaction,
      ) async {
    try {
      final result = await localDataSource.addTransaction(transaction);

      await analytics.logTransaction(
        transaction.id,
        transaction.amount,
        transaction.category,
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.uploadTransaction(transaction);
      }

      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction,
      ) async {
    try {
      final result = await localDataSource.updateTransaction(transaction);

      if (await networkInfo.isConnected) {
        await remoteDataSource.uploadTransaction(transaction);
      }

      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTransaction(id);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> filterTransactions({
    TransactionType? type,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await localDataSource.filterTransactions(
        type: type,
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}