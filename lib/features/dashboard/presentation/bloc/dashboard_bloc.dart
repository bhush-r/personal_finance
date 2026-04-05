import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_financial_summary.dart';
import '../../../transactions/domain/usecases/get_transactions.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetFinancialSummary getFinancialSummary;
  final GetTransactions getTransactions;

  DashboardBloc({
    required this.getFinancialSummary,
    required this.getTransactions,
  }) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
      DashboardEvent event,
      Emitter<DashboardState> emit,
      ) async {
    emit(const DashboardLoading());

    final summaryResult = await getFinancialSummary(NoParams());
    final transactionsResult = await getTransactions(NoParams());

    summaryResult.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (summary) {
        transactionsResult.fold(
              (failure) => emit(DashboardError(message: failure.message)),
              (transactions) {
            final recent = transactions.take(5).toList();
            emit(DashboardLoaded(summary: summary, recentTransactions: recent));
          },
        );
      },
    );
  }
}