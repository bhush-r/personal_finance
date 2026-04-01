import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction.dart';

class Insight extends Equatable {
  final TransactionCategory? topCategory;
  final double topCategoryAmount;
  final double thisWeekExpense;
  final double lastWeekExpense;
  final double weeklyDiff;
  final Map<TransactionCategory, double> categoryBreakdown;
  final List<MapEntry<DateTime, double>> monthlyTrend;

  const Insight({
    this.topCategory,
    required this.topCategoryAmount,
    required this.thisWeekExpense,
    required this.lastWeekExpense,
    required this.weeklyDiff,
    required this.categoryBreakdown,
    required this.monthlyTrend,
  });

  factory Insight.empty() => const Insight(
        topCategory: null,
        topCategoryAmount: 0,
        thisWeekExpense: 0,
        lastWeekExpense: 0,
        weeklyDiff: 0,
        categoryBreakdown: {},
        monthlyTrend: [],
      );

  @override
  List<Object?> get props => [
        topCategory,
        topCategoryAmount,
        thisWeekExpense,
        lastWeekExpense,
        weeklyDiff,
        categoryBreakdown,
        monthlyTrend,
      ];
}
