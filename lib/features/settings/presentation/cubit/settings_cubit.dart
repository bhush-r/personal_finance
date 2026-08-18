import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/usecases/get_preferences.dart';
import '../../domain/usecases/save_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetPreferences getPreferences;
  final SavePreferences savePreferences;
  final AuthRepository authRepository;

  SettingsCubit({
    required this.getPreferences,
    required this.savePreferences,
    required this.authRepository,
  }) : super(const SettingsInitial());

  /// Load user preferences
  Future<void> loadPreferences() async {
    try {
      emit(const SettingsLoading());
      final result = await getPreferences(NoParams());
      result.fold(
        (failure) => emit(SettingsError(message: failure.message)),
        (preferences) => emit(SettingsLoaded(preferences: preferences)),
      );
    } catch (e) {
      emit(SettingsError(message: 'Failed to load preferences: $e'));
    }
  }

  /// Save updated preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      emit(const SettingsLoading());
      final result = await savePreferences(
        SavePreferencesParams(preferences: preferences),
      );
      result.fold(
        (failure) => emit(SettingsError(message: failure.message)),
        (_) {
          emit(SettingsLoaded(preferences: preferences));
          Future.delayed(const Duration(milliseconds: 500), () {
            if (state is SettingsLoaded) {
              emit(SettingsSaved(message: 'Settings saved successfully'));
              Future.delayed(const Duration(seconds: 2), () {
                if (isClosed) return;
                emit(SettingsLoaded(preferences: preferences));
              });
            }
          });
        },
      );
    } catch (e) {
      emit(SettingsError(message: 'Failed to save preferences: $e'));
    }
  }

  Future<void> toggleDarkMode(bool isDark) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(darkMode: isDark);
      await updatePreferences(updated);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(enableNotifications: enabled);
      await updatePreferences(updated);
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(enableBiometric: enabled);
      await updatePreferences(updated);
    }
  }

  Future<void> updateCurrency(String currency) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(currency: currency);
      await updatePreferences(updated);
    }
  }

  Future<void> toggleReminders(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(enableReminders: enabled);
      await updatePreferences(updated);
    }
  }

  Future<void> updateLastExportDate() async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(lastDataExport: DateTime.now());
      await updatePreferences(updated);
    }
  }

  Future<void> logout() async {
    try {
      emit(const SettingsLoading());
      await authRepository.signOut();
      emit(const SettingsInitial());
    } catch (e) {
      emit(SettingsError(message: 'Logout failed: $e'));
    }
  }
}
