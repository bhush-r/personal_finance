import 'package:hive/hive.dart';
import '../../domain/entities/financial_summary.dart';
import '../../../transactions/data/models/transaction_model.dart';

abstract class DashboardLocalDataSource {
  Future<FinancialSummary> getFinancialSummary();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final Box<TransactionModel> box;

  DashboardLocalDataSourceImpl({required this.box});

  @override
  Future<FinancialSummary> getFinancialSummary() async {
    final transactions = box.values.toList();

    double totalIncome = 0;
    double totalExpense = 0;
    final categoryBreakdown = <String, double>{};
    final weeklyTrend = <String, double>{};

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    for (var i = 0; i < 7; i++) {
      final date = sevenDaysAgo.add(Duration(days: i));
      weeklyTrend['${date.weekday}'] = 0;
    }

    for (final txn in transactions) {
      final entity = txn.toEntity();
      if (entity.type.name == 'income') {
        totalIncome += entity.amount;
      } else {
        totalExpense += entity.amount;
      }

      final catName = entity.category.name.toLowerCase();
      categoryBreakdown[catName] = (categoryBreakdown[catName] ?? 0) + entity.amount;

      if (txn.date.isAfter(sevenDaysAgo)) {
        final dayKey = '${txn.date.weekday}';
        if (entity.type.name == 'expense') {
          weeklyTrend[dayKey] = (weeklyTrend[dayKey] ?? 0) + entity.amount;
        }
      }
    }

    final balance = totalIncome - totalExpense;

    return FinancialSummary(
      balance: balance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      savingsGoal: 50000,
      savingsProgress: balance > 0 ? balance : 0,
      categoryBreakdown: categoryBreakdown,
      weeklyTrend: [],
    );
  }
}