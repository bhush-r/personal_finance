import 'package:equatable/equatable.dart';
import '../../domain/entities/saving_streak.dart';

abstract class SavingStreakState extends Equatable {
  const SavingStreakState();

  @override
  List<Object?> get props => [];
}

class SavingStreakInitial extends SavingStreakState {
  const SavingStreakInitial();
}

class SavingStreakLoading extends SavingStreakState {
  const SavingStreakLoading();
}

class SavingStreakLoaded extends SavingStreakState {
  final List<SavingStreak> streaks;

  const SavingStreakLoaded({required this.streaks});

  @override
  List<Object?> get props => [streaks];
}

class StreakUpdated extends SavingStreakState {
  final SavingStreak streak;

  const StreakUpdated({required this.streak});

  @override
  List<Object?> get props => [streak];
}

class StreakBroken extends SavingStreakState {
  final SavingStreak streak;

  const StreakBroken({required this.streak});

  @override
  List<Object?> get props => [streak];
}

class SavingStreakError extends SavingStreakState {
  final String message;

  const SavingStreakError({required this.message});

  @override
  List<Object?> get props => [message];
}