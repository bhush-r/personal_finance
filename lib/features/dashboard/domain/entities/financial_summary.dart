import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction.dart';

class FinancialSummary extends Equatable {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final Map<TransactionCategory, double> categoryBreakdown;

  const FinancialSummary({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryBreakdown,
  });

  factory FinancialSummary.empty() => const FinancialSummary(
        balance: 0,
        totalIncome: 0,
        totalExpense: 0,
        categoryBreakdown: {},
      );

  factory FinancialSummary.fromTransactions(List<Transaction> transactions) {
    double income = 0;
    double expense = 0;
    final Map<TransactionCategory, double> breakdown = {};

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
        breakdown[t.category] = (breakdown[t.category] ?? 0) + t.amount;
      }
    }

    return FinancialSummary(
      balance: income - expense,
      totalIncome: income,
      totalExpense: expense,
      categoryBreakdown: breakdown,
    );
  }

  @override
  List<Object?> get props => [balance, totalIncome, totalExpense, categoryBreakdown];
}
