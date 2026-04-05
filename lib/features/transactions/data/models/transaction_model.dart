import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late int typeIndex;

  @HiveField(3)
  late int categoryIndex;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late String note;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.typeIndex,
    required this.categoryIndex,
    required this.date,
    required this.note,
  });

  factory TransactionModel.fromEntity(Transaction txn) => TransactionModel(
    id: txn.id,
    amount: txn.amount,
    typeIndex: txn.type.index,
    categoryIndex: txn.category.index,
    date: txn.date,
    note: txn.note,
  );

  Transaction toEntity() => Transaction(
    id: id,
    amount: amount,
    type: TransactionType.values[typeIndex],
    category: TransactionCategory.values[categoryIndex],
    date: date,
    note: note,
  );
}