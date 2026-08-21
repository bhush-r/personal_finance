part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {
  const LoadTransactionsEvent();
}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterTransactionsEvent extends TransactionEvent {
  final TransactionType? type;
  final String? category;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterTransactionsEvent({
    this.type,
    this.category,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, category, searchQuery, startDate, endDate];
}

class SortTransactionsEvent extends TransactionEvent {
  final String sortBy;

  const SortTransactionsEvent({required this.sortBy});

  @override
  List<Object?> get props => [sortBy];
}