import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/filter_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

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
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<FilterTransactionsEvent>(_onFilterTransactions);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());
    final result = await getTransactions(NoParams());
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (transactions) =>
          emit(TransactionLoaded(transactions: transactions)),
    );
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    final txn = event.transaction.copyWith(id: const Uuid().v4());
    final result =
    await addTransaction(AddTransactionParams(transaction: txn));
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (_) => add(LoadTransactions()),
    );
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    final result = await updateTransaction(
      UpdateTransactionParams(transaction: event.transaction),
    );
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (_) => add(LoadTransactions()),
    );
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    final result = await deleteTransaction(
      DeleteTransactionParams(id: event.id),
    );
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (_) => add(LoadTransactions()),
    );
  }

  Future<void> _onFilterTransactions(
      FilterTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());
    final result = await filterTransactions(
      FilterTransactionParams(
        type: event.type,
        category: event.category,
        searchQuery: event.searchQuery,
      ),
    );
    result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (transactions) =>
          emit(TransactionLoaded(transactions: transactions)),
    );
  }
}