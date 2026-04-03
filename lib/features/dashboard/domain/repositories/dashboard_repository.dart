import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/financial_summary.dart';

abstract class DashboardRepository {
  Future<Either<Failure, FinancialSummary>> getFinancialSummary();
}