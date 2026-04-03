import '../../../transactions/data/models/transaction_model.dart';
import 'package:hive/hive.dart';

abstract class InsightsLocalDataSource {
  Future<List<TransactionModel>> getAllTransactions();
}

class InsightsLocalDataSourceImpl implements InsightsLocalDataSource {
  final Box<TransactionModel> box;

  InsightsLocalDataSourceImpl({required this.box});

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    return box.values.toList();
  }
}