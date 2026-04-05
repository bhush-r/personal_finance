import 'package:equatable/equatable.dart';

enum StreakStatus { active, broken, paused }

class SavingStreak extends Equatable {
  final String id;
  final String title;
  final String description;
  final int currentStreak; // Days in a row
  final int longestStreak; // Personal best
  final double targetAmount; // Daily or weekly target
  final double totalSaved;
  final DateTime startDate;
  final DateTime? lastSavedDate;
  final DateTime? pausedDate;
  final StreakStatus status;
  final List<DateTime> streakDates; // Days when streak was maintained
  final int completedDays;

  const SavingStreak({
    required this.id,
    required this.title,
    required this.description,
    required this.currentStreak,
    required this.longestStreak,
    required this.targetAmount,
    required this.totalSaved,
    required this.startDate,
    this.lastSavedDate,
    this.pausedDate,
    this.status = StreakStatus.active,
    this.streakDates = const [],
    this.completedDays = 0,
  });

  /// Get streak percentage towards longest
  double getStreakProgress() {
    if (longestStreak == 0) return 0;
    return (currentStreak / longestStreak).clamp(0.0, 1.0);
  }

  /// Check if streak is about to break (no saving for 24 hours)
  bool isStreakAtRisk() {
    if (lastSavedDate == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastSavedDate!).inHours;
    return difference >= 23; // Breaking tomorrow
  }

  /// Get days until streak breaks
  int getDaysUntilBreak() {
    if (lastSavedDate == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(lastSavedDate!).inHours;
    return 24 - difference;
  }

  /// Check if target is met today
  bool isTargetMetToday() {
    if (lastSavedDate == null) return false;
    final now = DateTime.now();
    return lastSavedDate!.year == now.year &&
        lastSavedDate!.month == now.month &&
        lastSavedDate!.day == now.day;
  }

  /// Calculate savings per day
  double getSavingsPerDay() {
    if (completedDays == 0) return 0;
    return totalSaved / completedDays;
  }

  /// Get projected savings at current rate
  double getProjectedMonthlySavings() {
    return getSavingsPerDay() * 30;
  }

  SavingStreak copyWith({
    String? id,
    String? title,
    String? description,
    int? currentStreak,
    int? longestStreak,
    double? targetAmount,
    double? totalSaved,
    DateTime? startDate,
    DateTime? lastSavedDate,
    DateTime? pausedDate,
    StreakStatus? status,
    List<DateTime>? streakDates,
    int? completedDays,
  }) {
    return SavingStreak(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      targetAmount: targetAmount ?? this.targetAmount,
      totalSaved: totalSaved ?? this.totalSaved,
      startDate: startDate ?? this.startDate,
      lastSavedDate: lastSavedDate ?? this.lastSavedDate,
      pausedDate: pausedDate ?? this.pausedDate,
      status: status ?? this.status,
      streakDates: streakDates ?? this.streakDates,
      completedDays: completedDays ?? this.completedDays,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    currentStreak,
    longestStreak,
    targetAmount,
    totalSaved,
    startDate,
    lastSavedDate,
    pausedDate,
    status,
    streakDates,
    completedDays,
  ];
}