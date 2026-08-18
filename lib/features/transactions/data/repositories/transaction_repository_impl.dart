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
      // Always try to get from local first for speed.
      final localTransactions =
      await localDataSource.getTransactions();

      // Try to fetch remote data when internet is available.
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.getTransactions();

          // In a real application, remote and local data
          // can be merged using timestamps or IDs.
          //
          // For now, local data remains the source returned
          // to the UI.
        } catch (_) {
          // If remote fails, continue using local data.
        }
      }

      return Right(localTransactions);
    } catch (e) {
      return Left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
      Transaction transaction,
      ) async {
    try {
      // 1. Save locally.
      final result =
      await localDataSource.addTransaction(transaction);

      // 2. Log analytics.
      await analytics.logTransaction(
        transaction.id,
        transaction.amount,
        transaction.category.name,
      );

      // 3. Upload to Firebase when online.
      if (await networkInfo.isConnected) {
        await remoteDataSource.uploadTransaction(
          transaction,
        );
      } else {
        // Offline sync can be handled by a sync queue later.
      }

      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction,
      ) async {
    try {
      // 1. Update local database.
      final result =
      await localDataSource.updateTransaction(transaction);

      // 2. Upload updated transaction when online.
      if (await networkInfo.isConnected) {
        await remoteDataSource.uploadTransaction(
          transaction,
        );
      }

      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
      String id,
      ) async {
    try {
      // 1. Delete locally.
      await localDataSource.deleteTransaction(id);

      // 2. Delete from Firebase when online.
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTransaction(id);
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: e.toString(),
        ),
      );
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
      final transactions =
      await localDataSource.filterTransactions(
        type: type,
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(transactions);
    } catch (e) {
      return Left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }
}