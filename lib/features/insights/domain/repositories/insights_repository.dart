
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/insight.dart';

abstract class InsightsRepository {
  Future<Either<Failure, Insight>> getInsights();
}
