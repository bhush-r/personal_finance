import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/financial_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetFinancialSummary implements UseCase<FinancialSummary, NoParams> {
  final DashboardRepository repository;
  GetFinancialSummary(this.repository);

  @override
  Future<Either<Failure, FinancialSummary>> call(NoParams params) {
    return repository.getFinancialSummary();
  }
}