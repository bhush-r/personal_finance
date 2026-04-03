import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_financial_summary.dart';
import '../../../transactions/domain/usecases/get_transactions.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transactions/domain/entities/transaction.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetFinancialSummary getFinancialSummary;
  final GetTransactions getTransactions;

  DashboardBloc({
    required this.getFinancialSummary,
    required this.getTransactions,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event,
      Emitter<DashboardState> emit,
      ) async {
    emit(DashboardLoading());
    await _load(emit);
  }

  Future<void> _onRefreshDashboard(
      RefreshDashboard event,
      Emitter<DashboardState> emit,
      ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<DashboardState> emit) async {
    final summaryResult = await getFinancialSummary(NoParams());
    final txnResult = await getTransactions(NoParams());

    summaryResult.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (summary) {
        txnResult.fold(
              (failure) => emit(DashboardError(message: failure.message)),
              (transactions) {
            final recent = (List<Transaction>.from(transactions)
              ..sort((a, b) => b.date.compareTo(a.date)))
                .take(5)
                .toList();
            emit(DashboardLoaded(
              summary: summary,
              recentTransactions: recent,
            ));
          },
        );
      },
    );
  }
}