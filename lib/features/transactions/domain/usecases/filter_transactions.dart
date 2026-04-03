import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class FilterTransactions
    implements UseCase<List<Transaction>, FilterTransactionParams> {
  final TransactionRepository repository;
  FilterTransactions(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(
      FilterTransactionParams params) {
    return repository.filterTransactions(
      type: params.type,
      category: params.category,
      searchQuery: params.searchQuery,
    );
  }
}

class FilterTransactionParams extends Equatable {
  final TransactionType? type;
  final TransactionCategory? category;
  final String? searchQuery;

  const FilterTransactionParams({
    this.type,
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [type, category, searchQuery];
}