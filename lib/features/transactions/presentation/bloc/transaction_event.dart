import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  const AddTransactionEvent({required this.transaction});
  @override List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  const UpdateTransactionEvent({required this.transaction});
  @override List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;
  const DeleteTransactionEvent({required this.id});
  @override List<Object?> get props => [id];
}

class FilterTransactionsEvent extends TransactionEvent {
  final TransactionType? type;
  final TransactionCategory? category;
  final String? searchQuery;
  const FilterTransactionsEvent({this.type, this.category, this.searchQuery});
  @override List<Object?> get props => [type, category, searchQuery];
}


