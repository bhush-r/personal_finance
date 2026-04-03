import '../../../transactions/data/models/transaction_model.dart';
import 'package:hive/hive.dart';

abstract class DashboardLocalDataSource {
  Future<List<TransactionModel>> getAllTransactions();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final Box<TransactionModel> box;

  DashboardLocalDataSourceImpl({required this.box});

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    return box.values.toList();
  }
}