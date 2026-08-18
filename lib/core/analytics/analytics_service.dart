import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get analyticsObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Logs a custom event. 
  /// The [parameters] map must contain only [String], [int], [double], or [bool] values.
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logTransaction(String id, double amount, String category) async {
    await _analytics.logEvent(
      name: 'add_transaction',
      parameters: {
        'id': id,
        'amount': amount,
        'category': category,
      },
    );
  }

  Future<void> setUserProperties({required String userId}) async {
    await _analytics.setUserId(id: userId);
  }
}
