import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/utils/export_helper.dart';
import '../repositories/transaction_repository.dart';

class ExportTransactions implements UseCase<String, ExportTransactionsParams> {
  final TransactionRepository repository;

  ExportTransactions(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportTransactionsParams params) async {
    final result = await repository.getTransactions();

    return result.fold(
          (failure) => Left(failure),
          (transactions) {
        try {
          if (params.format.toLowerCase() == 'json') {
            final jsonStr = ExportHelper.transactionsToJSON(transactions);
            return Right(jsonStr);
          } else {
            final csvStr = ExportHelper.transactionsToCSV(transactions);
            return Right(csvStr);
          }
        } catch (e) {
          return Left(CacheFailure(message: 'Failed to format data: $e'));
        }
      },
    );
  }
}

class ExportTransactionsParams extends Equatable {
  final String format; // 'csv' or 'json'

  const ExportTransactionsParams({this.format = 'csv'});

  @override
  List<Object?> get props => [format];
}