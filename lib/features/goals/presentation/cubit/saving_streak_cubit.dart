import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/saving_streak.dart';
import 'saving_streak_state.dart';

class SavingStreakCubit extends Cubit<SavingStreakState> {
  // In-memory storage (replace with real repository later)
  final List<SavingStreak> _streaks = [];

  SavingStreakCubit() : super(const SavingStreakInitial());

  /// Load all saving streaks
  Future<void> loadStreaks() async {
    emit(const SavingStreakLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SavingStreakLoaded(streaks: _streaks));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  /// Create new saving streak
  Future<void> createStreak(SavingStreak streak) async {
    try {
      _streaks.add(streak);
      emit(SavingStreakLoaded(streaks: _streaks));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  /// Update streak when user saves
  Future<void> updateStreakWithSaving(
      String streakId,
      double amount,
      ) async {
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
        // New day of streak
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
      );

      _streaks[index] = updatedStreak;
      emit(SavingStreakLoaded(streaks: _streaks));
      emit(StreakUpdated(streak: updatedStreak));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  /// Break streak (when target not met for 24+ hours)
  Future<void> breakStreak(String streakId) async {
    try {
      final index = _streaks.indexWhere((s) => s.id == streakId);
      if (index == -1) return;

      final streak = _streaks[index];
      final updatedStreak = streak.copyWith(
        currentStreak: 0,
        status: StreakStatus.broken,
      );

      _streaks[index] = updatedStreak;
      emit(SavingStreakLoaded(streaks: _streaks));
      emit(StreakBroken(streak: updatedStreak));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  /// Pause streak
  Future<void> pauseStreak(String streakId) async {
    try {
      final index = _streaks.indexWhere((s) => s.id == streakId);
      if (index == -1) return;

      final streak = _streaks[index];
      final updatedStreak = streak.copyWith(
        status: StreakStatus.paused,
        pausedDate: DateTime.now(),
      );

      _streaks[index] = updatedStreak;
      emit(SavingStreakLoaded(streaks: _streaks));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  /// Resume streak
  Future<void> resumeStreak(String streakId) async {
    try {
      final index = _streaks.indexWhere((s) => s.id == streakId);
      if (index == -1) return;

      final streak = _streaks[index];
      final updatedStreak = streak.copyWith(
        status: StreakStatus.active,
        pausedDate: null,
      );

      _streaks[index] = updatedStreak;
      emit(SavingStreakLoaded(streaks: _streaks));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  /// Delete streak
  Future<void> deleteStreak(String streakId) async {
    try {
      _streaks.removeWhere((s) => s.id == streakId);
      emit(SavingStreakLoaded(streaks: _streaks));
    } catch (e) {
      emit(SavingStreakError(message: e.toString()));
    }
  }

  /// Get streak by ID
  SavingStreak? getStreakById(String id) {
    try {
      return _streaks.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get active streaks count
  int getActiveStreaksCount() {
    return _streaks.where((s) => s.status == StreakStatus.active).length;
  }

  /// Get total amount saved across all streaks
  double getTotalSavedAllStreaks() {
    return _streaks.fold(0, (sum, s) => sum + s.totalSaved);
  }
}