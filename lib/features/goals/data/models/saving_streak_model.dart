import 'package:hive/hive.dart';
import '../../domain/entities/saving_streak.dart';

part 'saving_streak_model.g.dart';

@HiveType(typeId: 2)
class SavingStreakModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late int currentStreak;

  @HiveField(4)
  late int longestStreak;

  @HiveField(5)
  late double targetAmount;

  @HiveField(6)
  late double totalSaved;

  @HiveField(7)
  late DateTime startDate;

  @HiveField(8)
  late DateTime? lastSavedDate;

  @HiveField(9)
  late DateTime? pausedDate;

  @HiveField(10)
  late int statusIndex;

  @HiveField(11)
  late List<DateTime> streakDates;

  @HiveField(12)
  late int completedDays;

  SavingStreakModel({
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
    required this.statusIndex,
    this.streakDates = const [],
    this.completedDays = 0,
  });

  factory SavingStreakModel.fromEntity(SavingStreak streak) {
    return SavingStreakModel(
      id: streak.id,
      title: streak.title,
      description: streak.description,
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      targetAmount: streak.targetAmount,
      totalSaved: streak.totalSaved,
      startDate: streak.startDate,
      lastSavedDate: streak.lastSavedDate,
      pausedDate: streak.pausedDate,
      statusIndex: streak.status.index,
      streakDates: streak.streakDates,
      completedDays: streak.completedDays,
    );
  }

  SavingStreak toEntity() {
    return SavingStreak(
      id: id,
      title: title,
      description: description,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      targetAmount: targetAmount,
      totalSaved: totalSaved,
      startDate: startDate,
      lastSavedDate: lastSavedDate,
      pausedDate: pausedDate,
      status: StreakStatus.values[statusIndex],
      streakDates: streakDates,
      completedDays: completedDays,
    );
  }
}
