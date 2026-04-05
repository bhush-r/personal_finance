import 'package:equatable/equatable.dart';

class Insight extends Equatable {
  final String topCategory;
  final double topCategoryAmount;
  final double thisWeekExpense;
  final double lastWeekExpense;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> monthlyTrend;
  final double averageDailySpend;

  const Insight({
    required this.topCategory,
    required this.topCategoryAmount,
    required this.thisWeekExpense,
    required this.lastWeekExpense,
    required this.categoryBreakdown,
    required this.monthlyTrend,
    required this.averageDailySpend,
  });

  double getWeeklyChange() {
    if (lastWeekExpense == 0) return 0;
    return ((thisWeekExpense - lastWeekExpense) / lastWeekExpense) * 100;
  }

  @override
  List<Object?> get props => [
    topCategory,
    topCategoryAmount,
    thisWeekExpense,
    lastWeekExpense,
    categoryBreakdown,
    monthlyTrend,
    averageDailySpend,
  ];
}