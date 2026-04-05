// lib/features/transactions/data/datasources/transaction_local_datasource.dart
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
    // Hive values are already in memory; toList() is efficient here for sorting
    final transactions = box.values.map((m) => m.toEntity()).toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    // Use ID as key for O(1) access
    await box.put(transaction.id, model);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    // Direct put using ID key
    await box.put(transaction.id, model);
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    // Direct delete using ID key
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
            t.category.name.toLowerCase().contains(query);
      }).toList();
    }

    // ✅ FIXED DATE LOGIC
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