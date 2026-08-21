import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/saving_streak.dart';
import 'saving_streak_state.dart';

class SavingStreakCubit extends Cubit<SavingStreakState> {
  final List<SavingStreak> _streaks = [];

  SavingStreakCubit() : super(const SavingStreakInitial());

  Future<void> loadStreaks() async {
    emit(const SavingStreakLoading());
    try {
      _checkAndUpdateExpiredStreaks();
      emit(SavingStreakLoaded(streaks: List.from(_streaks)));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  void _checkAndUpdateExpiredStreaks() {
    final now = DateTime.now();
    for (int i = 0; i < _streaks.length; i++) {
      final streak = _streaks[i];
      if (streak.status == StreakStatus.active && streak.lastSavedDate != null) {
        final hoursSinceLastSave = now.difference(streak.lastSavedDate!).inHours;
        if (hoursSinceLastSave >= 48) {
          _streaks[i] = streak.copyWith(
            currentStreak: 0,
            status: StreakStatus.broken,
          );
        }
      }
    }
  }

  Future<void> createStreak(SavingStreak streak) async {
    try {
      _streaks.add(streak);
      emit(SavingStreakLoaded(streaks: List.from(_streaks)));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  Future<void> updateStreakWithSaving(String streakId, double amount) async {
    try {
      final index = _streaks.indexWhere((s) => s.id == streakId);
      if (index == -1) return;

      final streak = _streaks[index];
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

      _streaks[index] = updatedStreak;
      emit(SavingStreakLoaded(streaks: List.from(_streaks)));
      emit(StreakUpdated(streak: updatedStreak));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  Future<void> pauseStreak(String streakId) async {
    try {
      final index = _streaks.indexWhere((s) => s.id == streakId);
      if (index == -1) return;

      final updatedStreak = _streaks[index].copyWith(
        status: StreakStatus.paused,
        pausedDate: DateTime.now(),
      );

      _streaks[index] = updatedStreak;
      emit(SavingStreakLoaded(streaks: List.from(_streaks)));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  Future<void> resumeStreak(String streakId) async {
    try {
      final index = _streaks.indexWhere((s) => s.id == streakId);
      if (index == -1) return;

      final updatedStreak = _streaks[index].copyWith(
        status: StreakStatus.active,
        pausedDate: null,
      );

      _streaks[index] = updatedStreak;
      emit(SavingStreakLoaded(streaks: List.from(_streaks)));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  Future<void> deleteStreak(String streakId) async {
    try {
      _streaks.removeWhere((s) => s.id == streakId);
      emit(SavingStreakLoaded(streaks: List.from(_streaks)));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }
}