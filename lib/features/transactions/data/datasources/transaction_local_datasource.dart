import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> cacheTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Box<TransactionModel> box;

  TransactionLocalDataSourceImpl({required this.box});

  @override
  Future<List<TransactionModel>> getTransactions() async {
    return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> cacheTransaction(TransactionModel transaction) async {
    await box.put(transaction.id, transaction);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await box.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await box.delete(id);
  }
}