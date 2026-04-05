import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences preferences);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences prefs;

  SettingsLocalDataSourceImpl({required this.prefs});

  @override
  Future<UserPreferences> getPreferences() async {
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');
    final darkMode = prefs.getBool('dark_mode') ?? false;
    final enableNotifications = prefs.getBool('enable_notifications') ?? true;
    final enableBiometric = prefs.getBool('enable_biometric') ?? false;
    final currency = prefs.getString('currency') ?? 'INR';
    final language = prefs.getString('language') ?? 'en';
    final lastBackupStr = prefs.getString('last_backup');
    final enableReminders = prefs.getBool('enable_reminders') ?? true;
    final enableDataExport = prefs.getBool('enable_data_export') ?? false;
    final lastDataExportStr = prefs.getString('last_data_export');

    return UserPreferences(
      userName: userName,
      userEmail: userEmail,
      darkMode: darkMode,
      enableNotifications: enableNotifications,
      enableBiometric: enableBiometric,
      currency: currency,
      language: language,
      lastBackup: lastBackupStr != null ? DateTime.parse(lastBackupStr) : null,
      enableReminders: enableReminders,
      enableDataExport: enableDataExport,
      lastDataExport:
      lastDataExportStr != null ? DateTime.parse(lastDataExportStr) : null,
    );
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    await Future.wait([
      if (preferences.userName != null)
        prefs.setString('user_name', preferences.userName!)
      else
        prefs.remove('user_name'),
      if (preferences.userEmail != null)
        prefs.setString('user_email', preferences.userEmail!)
      else
        prefs.remove('user_email'),
      prefs.setBool('dark_mode', preferences.darkMode),
      prefs.setBool('enable_notifications', preferences.enableNotifications),
      prefs.setBool('enable_biometric', preferences.enableBiometric),
      prefs.setString('currency', preferences.currency),
      prefs.setString('language', preferences.language),
      if (preferences.lastBackup != null)
        prefs.setString('last_backup', preferences.lastBackup!.toIso8601String())
      else
        prefs.remove('last_backup'),
      prefs.setBool('enable_reminders', preferences.enableReminders),
      prefs.setBool('enable_data_export', preferences.enableDataExport),
      if (preferences.lastDataExport != null)
        prefs.setString(
          'last_data_export',
          preferences.lastDataExport!.toIso8601String(),
        )
      else
        prefs.remove('last_data_export'),
    ]);
  }
}