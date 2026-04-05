import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String? userName;
  final String? userEmail;
  final bool darkMode;
  final bool enableNotifications;
  final bool enableBiometric;
  final String currency; // Currency code like 'INR', 'USD'
  final String language;
  final DateTime? lastBackup;
  final bool enableReminders; // ✨ NEW
  final bool enableDataExport; // ✨ NEW
  final DateTime? lastDataExport; // ✨ NEW

  const UserPreferences({
    this.userName,
    this.userEmail,
    this.darkMode = false,
    this.enableNotifications = true,
    this.enableBiometric = false,
    this.currency = 'INR',
    this.language = 'en',
    this.lastBackup,
    this.enableReminders = true,
    this.enableDataExport = false,
    this.lastDataExport,
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
    bool? enableReminders,
    bool? enableDataExport,
    DateTime? lastDataExport,
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
      enableReminders: enableReminders ?? this.enableReminders,
      enableDataExport: enableDataExport ?? this.enableDataExport,
      lastDataExport: lastDataExport ?? this.lastDataExport,
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
    enableReminders,
    enableDataExport,
    lastDataExport,
  ];
}