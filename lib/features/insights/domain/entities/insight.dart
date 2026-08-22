import 'package:equatable/equatable.dart';

class Insight extends Equatable {
  final String topCategory;
  final double topCategoryAmount;
  final double thisWeekExpense;
  final double lastWeekExpense;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> monthlyTrend;
  final double averageDailySpend;
  final Map<int, double> dailySpending; // 1: Mon, 7: Sun

  const Insight({
    required this.topCategory,
    required this.topCategoryAmount,
    required this.thisWeekExpense,
    required this.lastWeekExpense,
    required this.categoryBreakdown,
    required this.monthlyTrend,
    required this.averageDailySpend,
    required this.dailySpending,
  });

  /// Calculate weekly change percentage
  double getWeeklyChange() {
    if (lastWeekExpense == 0.0) return 0.0;
    return ((thisWeekExpense - lastWeekExpense) / lastWeekExpense) * 100.0;
  }

  /// Check if spending increased
  bool isSpendingIncreased() => getWeeklyChange() > 0.0;

  /// Get total spent across all categories
  double getTotalSpent() =>
      categoryBreakdown.values.fold(0.0, (sum, val) => sum + val);

  /// Get top 3 categories
  List<MapEntry<String, double>> getTopThreeCategories() {
    final sortedEntries = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).toList();
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
    dailySpending,
  ];
}
