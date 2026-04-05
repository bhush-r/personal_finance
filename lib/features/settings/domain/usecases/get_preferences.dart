import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_preferences.dart';
import '../repositories/settings_repository.dart';

class GetPreferences implements UseCase<UserPreferences, NoParams> {
  final SettingsRepository repository;

  GetPreferences(this.repository);

  @override
  Future<Either<Failure, UserPreferences>> call(NoParams params) {
    return repository.getPreferences();
  }
}