import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String? userName;
  final String? userEmail;
  final bool darkMode;
  final bool enableNotifications;
  final bool enableBiometric;
  final String currency;
  final String language;
  final DateTime? lastBackup;

  const UserPreferences({
    this.userName,
    this.userEmail,
    this.darkMode = false,
    this.enableNotifications = true,
    this.enableBiometric = false,
    this.currency = '₹',
    this.language = 'en',
    this.lastBackup,
  });

  UserPreferences copyWith({
    String? userName,
    String? userEmail,
    bool? darkMode,
    bool? enableNotifications,
    bool? enableBiometric,
    String? currency,
    String? language,
    DateTime? lastBackup,
  }) {
    return UserPreferences(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      darkMode: darkMode ?? this.darkMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }

  @override
  List<Object?> get props => [
    userName,
    userEmail,
    darkMode,
    enableNotifications,
    enableBiometric,
    currency,
    language,
    lastBackup,
  ];
}