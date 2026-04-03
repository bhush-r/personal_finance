import '../../../transactions/domain/entities/transaction.dart';

class SummaryModel {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final Map<TransactionCategory, double> categoryBreakdown;

  const SummaryModel({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryBreakdown,
  });
}