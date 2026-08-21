import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_financial_summary.dart';
import '../../../transactions/domain/usecases/get_transactions.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetFinancialSummary getFinancialSummary;
  final GetTransactions getTransactions;
  final TransactionBloc transactionBloc;
  StreamSubscription? _transactionSubscription;

  DashboardBloc({
    required this.getFinancialSummary,
    required this.getTransactions,
    required this.transactionBloc,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardSummary>(_onLoadDashboardSummary);

    // Listen to TransactionBloc state changes to keep Dashboard in sync
    _transactionSubscription = transactionBloc.stream.listen((state) {
      if (state is TransactionLoaded) {
        add(const LoadDashboardSummary());
      }
    });
  }

  Future<void> _onLoadDashboardSummary(
      LoadDashboardSummary event,
      Emitter<DashboardState> emit,
      ) async {
    emit(const DashboardLoading());

    final summaryResult = await getFinancialSummary(NoParams());
    final txnsResult = await getTransactions(NoParams());

    if (emit.isDone) return;

    summaryResult.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (summary) {
        txnsResult.fold(
              (failure) => emit(DashboardError(message: failure.message)),
              (transactions) => emit(
            DashboardLoaded(
              summary: summary,
              recentTransactions: transactions.take(5).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}