import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();

  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();

  @override
  List<Object?> get props => [];
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransactionOperationSuccess extends TransactionState {
  final String message;

  const TransactionOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}