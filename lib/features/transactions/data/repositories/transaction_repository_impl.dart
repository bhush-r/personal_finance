import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final transactions = await localDataSource.getTransactions();
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction) async {
    try {
      final result = await localDataSource.addTransaction(transaction);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction) async {
    try {
      final result = await localDataSource.updateTransaction(transaction);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
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