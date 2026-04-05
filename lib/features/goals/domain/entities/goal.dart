import 'package:equatable/equatable.dart';

enum GoalType { savings, noSpend, budgetCap, investment, debt }

class Goal extends Equatable {
  final String id;
  final String name;
  final GoalType type;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdDate;
  final DateTime? deadline;
  final String? description;
  final bool isCompleted;
  final int? noSpendDays; // For no-spend challenges

  const Goal({
    required this.id,
    required this.name,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdDate,
    this.deadline,
    this.description,
    this.isCompleted = false,
    this.noSpendDays = 0,
  });

  Goal copyWith({
    String? id,
    String? name,
    GoalType? type,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdDate,
    DateTime? deadline,
    String? description,
    bool? isCompleted,
    int? noSpendDays,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdDate: createdDate ?? this.createdDate,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      noSpendDays: noSpendDays ?? this.noSpendDays,
    );
  }

  double getProgress() {
    if (type == GoalType.noSpend) {
      return (noSpendDays ?? 0) / 30.0; // Assume 30 days goal
    }
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    targetAmount,
    currentAmount,
    createdDate,
    deadline,
    description,
    isCompleted,
    noSpendDays,
  ];
}