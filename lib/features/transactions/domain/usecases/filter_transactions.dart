import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class FilterTransactions implements UseCase<List<Transaction>, FilterTransactionsParams> {
  final TransactionRepository repository;

  FilterTransactions(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(FilterTransactionsParams params) {
    return repository.filterTransactions(
      type: params.type,
      searchQuery: params.searchQuery,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class FilterTransactionsParams extends Equatable {
  final TransactionType? type;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterTransactionsParams({
    this.type,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, searchQuery, startDate, endDate];
}