import 'package:flutter/services.dart';

class HapticFeedbackHelper {
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> success() async {
    await Future.wait([
      HapticFeedback.heavyImpact(),
      Future.delayed(const Duration(milliseconds: 100)),
    ]);
    await HapticFeedback.lightImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }
}