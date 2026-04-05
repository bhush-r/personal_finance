import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/insight.dart';
import '../repositories/insights_repository.dart';

class GetInsights implements UseCase<Insight, NoParams> {
  final InsightsRepository repository;

  GetInsights(this.repository);

  @override
  Future<Either<Failure, Insight>> call(NoParams params) {
    return repository.getInsights();
  }
}