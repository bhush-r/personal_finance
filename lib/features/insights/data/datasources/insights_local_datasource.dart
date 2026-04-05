import 'package:hive/hive.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/insight.dart';

abstract class InsightsLocalDataSource {
  Future<Insight> getInsights();
}

class InsightsLocalDataSourceImpl implements InsightsLocalDataSource {
  final Box<TransactionModel> box;

  InsightsLocalDataSourceImpl({required this.box});

  @override
  Future<Insight> getInsights() async {
    final transactions = box.values.toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate weekly data
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart;

    // Initialize tracking variables
    final categoryBreakdown = <String, double>{};
    double thisWeekExpense = 0;
    double lastWeekExpense = 0;
    final monthlyTrend = <String, double>{};
    int expenseCount = 0;

    // Process each transaction
    for (final txn in transactions) {
      final entity = txn.toEntity();

      // Only process expenses
      if (entity.type.name != 'expense') continue;

      final catName = entity.category.name.toLowerCase();
      final amount = entity.amount;

      // Update category breakdown
      categoryBreakdown[catName] = (categoryBreakdown[catName] ?? 0) + amount;

      // This week expenses
      if (txn.date.isAfter(thisWeekStart.subtract(const Duration(seconds: 1)))) {
        thisWeekExpense += amount;
      }

      // Last week expenses
      if (txn.date.isAfter(lastWeekStart.subtract(const Duration(seconds: 1))) &&
          txn.date.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
        lastWeekExpense += amount;
      }

      // Monthly trend
      final monthKey = '${txn.date.year}-${txn.date.month.toString().padLeft(2, '0')}';
      monthlyTrend[monthKey] = (monthlyTrend[monthKey] ?? 0) + amount;

      expenseCount++;
    }

    // Find top category
    String topCategory = 'other';
    double topCategoryAmount = 0;
    categoryBreakdown.forEach((key, value) {
      if (value > topCategoryAmount) {
        topCategoryAmount = value;
        topCategory = key;
      }
    });


    final averageDailySpend = expenseCount > 0
        ? thisWeekExpense / 7.0
        : 0.0;

    return Insight(
      topCategory: topCategory,
      topCategoryAmount: topCategoryAmount,
      thisWeekExpense: thisWeekExpense,
      lastWeekExpense: lastWeekExpense,
      categoryBreakdown: categoryBreakdown,
      monthlyTrend: monthlyTrend,
      averageDailySpend: averageDailySpend,
    );
  }
}