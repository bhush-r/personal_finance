import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions implements UseCase<List<Transaction>, NoParams> {
  final TransactionRepository repository;
  GetTransactions(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) {
    return repository.getTransactions();
  }
}