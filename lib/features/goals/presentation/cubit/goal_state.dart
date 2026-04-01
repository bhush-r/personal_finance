import 'package:equatable/equatable.dart';
import '../../domain/entities/goal.dart';

abstract class GoalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {}

class GoalLoading extends GoalState {}

class GoalLoaded extends GoalState {
  final List<Goal> goals;
  const GoalLoaded({required this.goals});

  @override
  List<Object?> get props => [goals];
}

class GoalError extends GoalState {
  final String message;
  const GoalError({required this.message});

  @override
  List<Object?> get props => [message];
}
