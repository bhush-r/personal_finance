import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final models = await localDataSource.getTransactions();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(Transaction txn) async {
    try {
      final model = TransactionModel.fromEntity(txn);
      await localDataSource.cacheTransaction(model);
      return Right(txn);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(Transaction txn) async {
    try {
      final model = TransactionModel.fromEntity(txn);
      await localDataSource.updateTransaction(model);
      return Right(txn);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(true);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> filterTransactions({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
  }) async {
    try {
      var txns = (await localDataSource.getTransactions()).map((m) => m.toEntity()).toList();

      if (type != null) txns = txns.where((t) => t.type == type).toList();
      if (category != null) txns = txns.where((t) => t.category == category).toList();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        txns = txns.where((t) => t.note.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }

      return Right(txns);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}