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

    // Monday as start of week
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart;

    final categoryBreakdown = <String, double>{};
    double thisWeekExpense = 0;
    double lastWeekExpense = 0;
    final monthlyTrend = <String, double>{};
    final dailySpending = <int, double>{
      1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0
    };
    int expenseCount = 0;

    for (final txn in transactions) {
      final entity = txn.toEntity();

      // Only evaluate expense entries
      if (entity.type.name != 'expense') continue;

      final catName = entity.category.trim();
      final amount = entity.amount;

      categoryBreakdown[catName] = (categoryBreakdown[catName] ?? 0) + amount;

      if (txn.date.isAfter(thisWeekStart.subtract(const Duration(seconds: 1)))) {
        thisWeekExpense += amount;
        
        // Populate daily spending for this week
        final weekday = txn.date.weekday;
        dailySpending[weekday] = (dailySpending[weekday] ?? 0) + amount;
      }

      if (txn.date.isAfter(lastWeekStart.subtract(const Duration(seconds: 1))) &&
          txn.date.isBefore(lastWeekEnd)) {
        lastWeekExpense += amount;
      }

      final monthKey = '${txn.date.year}-${txn.date.month.toString().padLeft(2, '0')}';
      monthlyTrend[monthKey] = (monthlyTrend[monthKey] ?? 0) + amount;

      expenseCount++;
    }

    String topCategory = 'Other';
    double topCategoryAmount = 0;
    categoryBreakdown.forEach((key, value) {
      if (value > topCategoryAmount) {
        topCategoryAmount = value;
        topCategory = key;
      }
    });

    final averageDailySpend = expenseCount > 0 ? thisWeekExpense / 7.0 : 0.0;

    return Insight(
      topCategory: topCategory,
      topCategoryAmount: topCategoryAmount,
      thisWeekExpense: thisWeekExpense,
      lastWeekExpense: lastWeekExpense,
      categoryBreakdown: categoryBreakdown,
      monthlyTrend: monthlyTrend,
      averageDailySpend: averageDailySpend,
      dailySpending: dailySpending,
    );
  }
}
