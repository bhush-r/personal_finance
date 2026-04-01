import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);
  Future<Either<Failure, bool>> deleteTransaction(String id);
  Future<Either<Failure, List<Transaction>>> filterTransactions({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    String? searchQuery,
  });
}