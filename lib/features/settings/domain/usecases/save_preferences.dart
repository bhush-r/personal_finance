import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_preferences.dart';
import '../repositories/settings_repository.dart';

class SavePreferences implements UseCase<void, SavePreferencesParams> {
  final SettingsRepository repository;

  SavePreferences(this.repository);

  @override
  Future<Either<Failure, void>> call(SavePreferencesParams params) {
    return repository.savePreferences(params.preferences);
  }
}

class SavePreferencesParams extends Equatable {
  final UserPreferences preferences;

  const SavePreferencesParams({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}