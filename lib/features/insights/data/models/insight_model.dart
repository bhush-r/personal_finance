import '../../domain/entities/insight.dart';

class InsightModel extends Insight {
  const InsightModel({
    required super.topCategory,
    required super.topCategoryAmount,
    required super.thisWeekExpense,
    required super.lastWeekExpense,
    required super.categoryBreakdown,
    required super.monthlyTrend,
    required super.averageDailySpend,
    required super.dailySpending,
  });

  factory InsightModel.fromTransactions(List<dynamic> transactions) {
    // This logic will be moved to data source or handled here
    // For now, providing a way to construct it
    return InsightModel(
      topCategory: 'Food',
      topCategoryAmount: 0.0,
      thisWeekExpense: 0.0,
      lastWeekExpense: 0.0,
      categoryBreakdown: const {},
      monthlyTrend: const {},
      averageDailySpend: 0.0,
      dailySpending: const {},
    );
  }
}
