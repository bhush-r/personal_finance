import 'package:equatable/equatable.dart';

class FinancialSummary extends Equatable {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final double savingsGoal;
  final double savingsProgress;
  final Map<String, double> categoryBreakdown;
  final List<DailySpending> weeklyTrend;

  const FinancialSummary({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.savingsGoal,
    required this.savingsProgress,
    required this.categoryBreakdown,
    required this.weeklyTrend,
  });

  @override
  List<Object?> get props => [
    balance,
    totalIncome,
    totalExpense,
    savingsGoal,
    savingsProgress,
    categoryBreakdown,
    weeklyTrend,
  ];
}

class DailySpending extends Equatable {
  final String day;
  final double amount;
  final DateTime date;

  const DailySpending({
    required this.day,
    required this.amount,
    required this.date,
  });

  @override
  List<Object?> get props => [day, amount, date];
}