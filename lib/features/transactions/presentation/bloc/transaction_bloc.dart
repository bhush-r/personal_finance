import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/filter_transactions.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final FilterTransactions filterTransactions;

  List<Transaction> _allTransactions = [];

  TransactionBloc({
    required this.getTransactions,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.filterTransactions,
  }) : super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<FilterTransactionsEvent>(_onFilterTransactions);
    on<SortTransactionsEvent>(_onSortTransactions);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());
    final result = await getTransactions(NoParams());
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (transactions) {
        _allTransactions = transactions;
        emit(TransactionLoaded(transactions: transactions));
      },
    );
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    final result = await addTransaction(
      AddTransactionParams(transaction: event.transaction),
    );

    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (_) => add(const LoadTransactions()),
    );
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());
    final result = await updateTransaction(
      UpdateTransactionParams(transaction: event.transaction),
    );
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (_) {
        // Reload transactions without await
        _loadAndRefresh(emit);
      },
    );
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());
    final result = await deleteTransaction(
      DeleteTransactionParams(id: event.id),
    );
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (_) {
        // Reload transactions without await
        _loadAndRefresh(emit);
      },
    );
  }

  Future<void> _onFilterTransactions(
      FilterTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());
    final result = await filterTransactions(
      FilterTransactionsParams(
        type: event.type,
        searchQuery: event.searchQuery,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (transactions) => emit(TransactionLoaded(transactions: transactions)),
    );
  }

  Future<void> _onSortTransactions(
      SortTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    if (_allTransactions.isEmpty) return;

    List<Transaction> sorted = List.from(_allTransactions);

    switch (event.sortBy) {
      case 'date_asc':
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_desc':
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'amount_asc':
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'amount_desc':
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
    }

    emit(TransactionLoaded(transactions: sorted));
  }


  Future<void> _loadAndRefresh(Emitter<TransactionState> emit) async {
    final loadResult = await getTransactions(NoParams());
    loadResult.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (transactions) {
        _allTransactions = transactions;
        emit(TransactionLoaded(transactions: transactions));
        emit(const TransactionOperationSuccess(
          message: '✓ Transaction operation successful',
        ));
      },
    );
  }
}