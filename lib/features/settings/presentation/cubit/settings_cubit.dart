import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/usecases/get_preferences.dart';
import '../../domain/usecases/save_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetPreferences getPreferences;
  final SavePreferences savePreferences;

  SettingsCubit({
    required this.getPreferences,
    required this.savePreferences,
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
          // Show success message briefly
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

  /// Update dark mode setting
  Future<void> toggleDarkMode(bool isDark) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(darkMode: isDark);
      await updatePreferences(updated);
    }
  }

  /// Update notifications setting
  Future<void> toggleNotifications(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(enableNotifications: enabled);
      await updatePreferences(updated);
    }
  }

  /// Update biometric setting
  Future<void> toggleBiometric(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(enableBiometric: enabled);
      await updatePreferences(updated);
    }
  }

  /// Update currency setting
  Future<void> updateCurrency(String currency) async {
    if (state is SettingsLoaded) {
      final currentPrefs = (state as SettingsLoaded).preferences;
      final updated = currentPrefs.copyWith(currency: currency);
      await updatePreferences(updated);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      emit(const SettingsLoading());
      // TODO: Implement logout logic (clear storage, navigate to login, etc.)
      // For now, just reset to initial state
      emit(const SettingsInitial());
    } catch (e) {
      emit(SettingsError(message: 'Logout failed: $e'));
    }
  }
}