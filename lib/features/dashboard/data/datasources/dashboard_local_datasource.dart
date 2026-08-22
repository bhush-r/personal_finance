import 'package:hive/hive.dart';
import '../../domain/entities/financial_summary.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction.dart';
import 'package:intl/intl.dart';

abstract class DashboardLocalDataSource {
  Future<FinancialSummary> getFinancialSummary();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final Box<TransactionModel> box;

  DashboardLocalDataSourceImpl({required this.box});

  @override
  Future<FinancialSummary> getFinancialSummary() async {
    final transactions = box.values.map((m) => m.toEntity()).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryBreakdown = {};
    
    // Weekly trend calculation (last 7 days)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7Days = List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));
    final Map<DateTime, double> dailyAmounts = {for (var d in last7Days) d: 0.0};

    for (final txn in transactions) {
      if (txn.type == TransactionType.income) {
        totalIncome += txn.amount;
      } else if (txn.type == TransactionType.expense) {
        totalExpense += txn.amount;
        final cat = txn.category.trim();
        categoryBreakdown[cat] = (categoryBreakdown[cat] ?? 0) + txn.amount;
        
        final txnDate = DateTime(txn.date.year, txn.date.month, txn.date.day);
        if (dailyAmounts.containsKey(txnDate)) {
          dailyAmounts[txnDate] = (dailyAmounts[txnDate] ?? 0) + txn.amount;
        }
      }
    }

    final weeklyTrend = last7Days.map((date) {
      return DailySpending(
        day: DateFormat('E').format(date).substring(0, 1), // M, T, W...
        amount: dailyAmounts[date] ?? 0.0,
        date: date,
      );
    }).toList();

    final balance = totalIncome - totalExpense;

    return FinancialSummary(
      balance: balance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      savingsGoal: 10000.0,
      savingsProgress: totalIncome > 0 ? (balance / totalIncome).clamp(0.0, 1.0) : 0.0,
      categoryBreakdown: categoryBreakdown,
      weeklyTrend: weeklyTrend,
    );
  }
}
