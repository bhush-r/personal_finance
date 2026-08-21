import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final int typeIndex; // Aligned with the adapter expectation (0 = expense, 1 = income)

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String note;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.typeIndex,
    required this.category,
    required this.date,
    required this.note,
  });

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      typeIndex: transaction.type == TransactionType.income ? 1 : 0,
      category: transaction.category,
      date: transaction.date,
      note: transaction.note,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      type: typeIndex == 1 ? TransactionType.income : TransactionType.expense,
      category: category,
      date: date,
      note: note,
    );
  }
}