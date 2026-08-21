import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/filter_transactions.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final FilterTransactions filterTransactions;

  TransactionBloc({
    required this.getTransactions,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.filterTransactions,
  }) : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<FilterTransactionsEvent>(_onFilterTransactions);
    on<SortTransactionsEvent>(_onSortTransactions);
  }

  Future<void> _onLoadTransactions(
      LoadTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    final result = await getTransactions(NoParams());

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(TransactionError(failure.message)),
          (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    final result = await addTransaction(
      AddTransactionParams(transaction: event.transaction),
    );

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(TransactionError(failure.message)),
          (_) => add(const LoadTransactionsEvent()),
    );
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    final result = await updateTransaction(
      UpdateTransactionParams(transaction: event.transaction),
    );

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(TransactionError(failure.message)),
          (_) => add(const LoadTransactionsEvent()),
    );
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    final result = await deleteTransaction(
      DeleteTransactionParams(id: event.id),
    );

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(TransactionError(failure.message)),
          (_) => add(const LoadTransactionsEvent()),
    );
  }

  Future<void> _onFilterTransactions(
      FilterTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    final result = await filterTransactions(
      FilterTransactionsParams(
        type: event.type,
        category: event.category,
        searchQuery: event.searchQuery,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(TransactionError(failure.message)),
          (filteredTransactions) => emit(TransactionLoaded(filteredTransactions)),
    );
  }

  Future<void> _onSortTransactions(
      SortTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    if (state is TransactionLoaded) {
      final currentTxns = List<Transaction>.from(
        (state as TransactionLoaded).transactions,
      );

      switch (event.sortBy) {
        case 'date_desc':
          currentTxns.sort((a, b) => b.date.compareTo(a.date));
          break;
        case 'date_asc':
          currentTxns.sort((a, b) => a.date.compareTo(b.date));
          break;
        case 'amount_desc':
          currentTxns.sort((a, b) => b.amount.compareTo(a.amount));
          break;
        case 'amount_asc':
          currentTxns.sort((a, b) => a.amount.compareTo(b.amount));
          break;
      }

      emit(TransactionLoaded(currentTxns));
    }
  }
}