import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class ExportTransactions implements UseCase<String, ExportTransactionsParams> {
  final TransactionRepository repository;

  ExportTransactions(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportTransactionsParams params) async {
    try {
      final transactions = await repository.getTransactions();
      return transactions.fold(
            (failure) => Left(failure),
            (txns) {
          // Generate CSV
          final csv = _generateCSV(txns);
          return Right(csv);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  String _generateCSV(dynamic txns) {
    StringBuffer csv = StringBuffer();
    csv.writeln('Date,Amount,Type,Category,Note');

    for (var txn in txns) {
      csv.writeln(
        '${txn.date.toIso8601String()},${txn.amount},${txn.type.name},${txn.category.name},${txn.note}',
      );
    }

    return csv.toString();
  }
}

class ExportTransactionsParams extends Equatable {
  final String format; // 'csv', 'json'

  const ExportTransactionsParams({this.format = 'csv'});

  @override
  List<Object?> get props => [format];
}