import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;

  const DeleteTransactionEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class FilterTransactionsEvent extends TransactionEvent {
  final TransactionType? type;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterTransactionsEvent({
    this.type,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, searchQuery, startDate, endDate];
}

class SortTransactionsEvent extends TransactionEvent {
  final String sortBy; // 'date_asc', 'date_desc', 'amount_asc', 'amount_desc'

  const SortTransactionsEvent({required this.sortBy});

  @override
  List<Object?> get props => [sortBy];
}