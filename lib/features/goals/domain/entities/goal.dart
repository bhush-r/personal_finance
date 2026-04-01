
import 'package:equatable/equatable.dart';

enum GoalType { savings, noSpend, budgetCap }

class Goal extends Equatable {
  final String id;
  final String title;
  final GoalType type;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final int streakDays;         // for noSpend challenges
  final String? category;       // for noSpend / budgetCap

  const Goal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.streakDays = 0,
    this.category,
  });

  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  bool get isCompleted => currentAmount >= targetAmount;

  Goal copyWith({
    String? id, String? title, GoalType? type,
    double? targetAmount, double? currentAmount,
    DateTime? deadline, int? streakDays, String? category,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      streakDays: streakDays ?? this.streakDays,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [id, title, type, targetAmount, currentAmount, deadline, streakDays];
}