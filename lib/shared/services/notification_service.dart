import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart' show debugPrint;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize timezone
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings iOSInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    try {
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      // ✅ Request exact alarm permission on Android 13+
      await _requestExactAlarmPermission();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Request exact alarm permission for Android 13+
  Future<void> _requestExactAlarmPermission() async {
    try {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
    }
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription:
        'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Schedule a notification to be shown at a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        channelDescription:
        'This channel is used for scheduled notifications.',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
      );

      // ✅ FIXED: Added androidScheduleMode (required in v14+)
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NOTIFICATION HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  /// Send notification when a transaction is added
  Future<void> sendTransactionAddedNotification(
      String category,
      double amount,
      ) async {
    await showNotification(
      id: 1,
      title: 'Transaction Added',
      body: '$category - ₹$amount',
    );
  }

  /// Send notification when budget is exceeded
  Future<void> sendBudgetExceededNotification(
      String category,
      double limit,
      double spent,
      ) async {
    await showNotification(
      id: 2,
      title: 'Budget Exceeded!',
      body: '$category: ₹$spent / ₹$limit',
    );
  }

  /// Send notification for goal progress
  Future<void> sendGoalProgressNotification(
      String goalName,
      double progress,
      ) async {
    await showNotification(
      id: 3,
      title: 'Goal Progress',
      body: '$goalName: ${(progress * 100).toStringAsFixed(0)}% complete',
    );
  }

  /// Schedule a daily reminder notification
  Future<void> sendDailyReminderNotification() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1)).copyWith(
      hour: 8,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    await scheduleNotification(
      id: 4,
      title: 'Daily Reminder',
      body: 'Check your spending today',
      scheduledDate: tomorrow,
    );
  }

  /// Schedule a weekly spending review notification
  Future<void> sendWeeklyReviewNotification() async {
    final nextMonday = _getNextMonday().copyWith(
      hour: 10,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    await scheduleNotification(
      id: 5,
      title: 'Weekly Review',
      body: 'Review your spending this week',
      scheduledDate: nextMonday,
    );
  }

  /// Get the date of next Monday
  DateTime _getNextMonday() {
    DateTime now = DateTime.now();
    int daysUntilMonday = (DateTime.monday - now.weekday) % 7;
    if (daysUntilMonday <= 0) daysUntilMonday += 7;
    return now.add(Duration(days: daysUntilMonday));
  }
}