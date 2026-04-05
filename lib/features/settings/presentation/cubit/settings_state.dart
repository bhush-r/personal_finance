import 'package:equatable/equatable.dart';
import '../../domain/entities/user_preferences.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final UserPreferences preferences;

  const SettingsLoaded({required this.preferences});

  // ✅ ADDED: Getters for easy access
  bool get darkMode => preferences.darkMode;
  bool get notificationsEnabled => preferences.enableNotifications;
  bool get biometricEnabled => preferences.enableBiometric;
  String get currency => preferences.currency;

  @override
  List<Object?> get props => [preferences];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SettingsSaved extends SettingsState {
  final String message;

  const SettingsSaved({required this.message});

  @override
  List<Object?> get props => [message];
}