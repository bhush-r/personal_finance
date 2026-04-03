import 'package:equatable/equatable.dart';
import '../../domain/entities/financial_summary.dart';
import '../../../transactions/domain/entities/transaction.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}


class DashboardInitial extends DashboardState {
  const DashboardInitial();
}


class DashboardLoading extends DashboardState {
  const DashboardLoading();
}


class DashboardLoaded extends DashboardState {
  final FinancialSummary summary;
  final List<Transaction> recentTransactions;

  const DashboardLoaded({
    required this.summary,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [summary, recentTransactions];
}


class DashboardError extends DashboardState {
  final String message;

  const DashboardError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}