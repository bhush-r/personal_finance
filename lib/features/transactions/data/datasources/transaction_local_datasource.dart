import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionLocalDataSource {
  Future<List<Transaction>> getTransactions();
  Future<Transaction> addTransaction(Transaction transaction);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<List<Transaction>> filterTransactions({
    TransactionType? type,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Box<TransactionModel> box;

  TransactionLocalDataSourceImpl({required this.box});

  @override
  Future<List<Transaction>> getTransactions() async {
    final transactions = box.values.map((m) => m.toEntity()).toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await box.put(transaction.id, model);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await box.put(transaction.id, model);
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await box.delete(id);
  }

  @override
  Future<List<Transaction>> filterTransactions({
    TransactionType? type,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var transactions = await getTransactions();

    if (type != null) {
      transactions = transactions.where((t) => t.type == type).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      transactions = transactions.where((t) {
        return t.note.toLowerCase().contains(query) ||
            t.category.toLowerCase().contains(query);
      }).toList();
    }

    if (startDate != null) {
      transactions = transactions.where(
            (t) => !t.date.isBefore(startDate),
      ).toList();
    }

    if (endDate != null) {
      transactions = transactions.where(
            (t) => !t.date.isAfter(endDate),
      ).toList();
    }

    return transactions;
  }
}