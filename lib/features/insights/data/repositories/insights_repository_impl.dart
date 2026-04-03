import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/insight.dart';
import '../../domain/repositories/insights_repository.dart';
import '../datasources/insights_local_datasource.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../../core/extensions/date_extension.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  final InsightsLocalDataSource localDataSource;

  InsightsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Insight>> getInsights() async {
    try {
      final models = await localDataSource.getAllTransactions();
      final transactions =
      models.map((m) => m.toEntity()).toList();
      return Right(_computeInsights(transactions));
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  Insight _computeInsights(List<Transaction> transactions) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    // Category breakdown
    final Map<TransactionCategory, double> categoryBreakdown = {};
    for (final t in expenses) {
      categoryBreakdown[t.category] =
          (categoryBreakdown[t.category] ?? 0) + t.amount;
    }

    // Top category
    TransactionCategory? topCategory;
    double topCategoryAmount = 0;
    categoryBreakdown.forEach((cat, amount) {
      if (amount > topCategoryAmount) {
        topCategoryAmount = amount;
        topCategory = cat;
      }
    });

    // Weekly comparison
    final now = DateTime.now();
    final thisWeekStart = now.startOfWeek;
    final lastWeekStart =
    thisWeekStart.subtract(const Duration(days: 7));

    double thisWeekExpense = 0;
    double lastWeekExpense = 0;
    for (final t in expenses) {
      if (!t.date.isBefore(thisWeekStart)) {
        thisWeekExpense += t.amount;
      } else if (!t.date.isBefore(lastWeekStart)) {
        lastWeekExpense += t.amount;
      }
    }
    final weeklyDiff = thisWeekExpense - lastWeekExpense;

    // Monthly trend (last 6 months)
    final monthlyMap = <DateTime, double>{};
    for (int i = 5; i >= 0; i--) {
      // Compute month correctly across year boundaries
      int y = now.year;
      int m = now.month - i;
      while (m <= 0) {
        m += 12;
        y -= 1;
      }
      final month = DateTime(y, m, 1);
      monthlyMap[month] = 0;
    }
    for (final t in expenses) {
      final monthKey = DateTime(t.date.year, t.date.month, 1);
      if (monthlyMap.containsKey(monthKey)) {
        monthlyMap[monthKey] = (monthlyMap[monthKey] ?? 0) + t.amount;
      }
    }
    final monthlyTrend =
    monthlyMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Insight(
      topCategory: topCategory,
      topCategoryAmount: topCategoryAmount,
      thisWeekExpense: thisWeekExpense,
      lastWeekExpense: lastWeekExpense,
      weeklyDiff: weeklyDiff,
      categoryBreakdown: categoryBreakdown,
      monthlyTrend: monthlyTrend,
    );
  }
}