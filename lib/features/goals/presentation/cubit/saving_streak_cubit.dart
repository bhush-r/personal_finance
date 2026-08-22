import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../data/models/saving_streak_model.dart';
import '../../domain/entities/saving_streak.dart';
import 'saving_streak_state.dart';

class SavingStreakCubit extends Cubit<SavingStreakState> {
  final Box<SavingStreakModel> box;

  SavingStreakCubit({required this.box}) : super(const SavingStreakInitial());

  Future<void> loadStreaks() async {
    emit(const SavingStreakLoading());
    try {
      final streaks = box.values.map((m) => m.toEntity()).toList();
      final updatedStreaks = _checkAndUpdateExpiredStreaks(streaks);
      
      // Save back updated streaks if any changed
      for (var streak in updatedStreaks) {
        final model = SavingStreakModel.fromEntity(streak);
        await box.put(model.id, model);
      }
      
      emit(SavingStreakLoaded(streaks: updatedStreaks));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  List<SavingStreak> _checkAndUpdateExpiredStreaks(List<SavingStreak> streaks) {
    final now = DateTime.now();
    return streaks.map((streak) {
      if (streak.status == StreakStatus.active && streak.lastSavedDate != null) {
        final hoursSinceLastSave = now.difference(streak.lastSavedDate!).inHours;
        if (hoursSinceLastSave >= 48) {
          return streak.copyWith(
            currentStreak: 0,
            status: StreakStatus.broken,
          );
        }
      }
      return streak;
    }).toList();
  }

  Future<void> createStreak(SavingStreak streak) async {
    try {
      final model = SavingStreakModel.fromEntity(streak);
      await box.put(model.id, model);
      await loadStreaks();
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  Future<void> updateStreakWithSaving(String streakId, double amount) async {
    try {
      final model = box.get(streakId);
      if (model == null) return;

      final streak = model.toEntity();
      final now = DateTime.now();
      final isToday = streak.lastSavedDate != null &&
          streak.lastSavedDate!.year == now.year &&
          streak.lastSavedDate!.month == now.month &&
          streak.lastSavedDate!.day == now.day;

      int newCurrentStreak = streak.currentStreak;
      int newLongestStreak = streak.longestStreak;
      int newCompletedDays = streak.completedDays;

      if (!isToday) {
        newCurrentStreak = streak.currentStreak + 1;
        newLongestStreak = newCurrentStreak > streak.longestStreak
            ? newCurrentStreak
            : streak.longestStreak;
        newCompletedDays = streak.completedDays + 1;
      }

      final updatedStreak = streak.copyWith(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        totalSaved: streak.totalSaved + amount,
        lastSavedDate: now,
        completedDays: newCompletedDays,
        status: StreakStatus.active,
      );

      final updatedModel = SavingStreakModel.fromEntity(updatedStreak);
      await box.put(streakId, updatedModel);
      
      await loadStreaks();
      emit(StreakUpdated(streak: updatedStreak));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  Future<void> pauseStreak(String streakId) async {
    try {
      final model = box.get(streakId);
      if (model == null) return;

      final updatedStreak = model.toEntity().copyWith(
        status: StreakStatus.paused,
        pausedDate: DateTime.now(),
      );

      await box.put(streakId, SavingStreakModel.fromEntity(updatedStreak));
      await loadStreaks();
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  Future<void> resumeStreak(String streakId) async {
    try {
      final model = box.get(streakId);
      if (model == null) return;

      final updatedStreak = model.toEntity().copyWith(
        status: StreakStatus.active,
        pausedDate: null,
      );

      await box.put(streakId, SavingStreakModel.fromEntity(updatedStreak));
      await loadStreaks();
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  Future<void> deleteStreak(String streakId) async {
    try {
      await box.delete(streakId);
      await loadStreaks();
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }
}
