import 'package:hive/hive.dart';
import '../../domain/entities/goal.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 1)
class GoalModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int typeIndex; // GoalType.index

  @HiveField(3)
  late double targetAmount;

  @HiveField(4)
  late double currentAmount;

  @HiveField(5)
  late DateTime createdDate;

  @HiveField(6)
  late DateTime? deadline;

  @HiveField(7)
  late String? description;

  @HiveField(8)
  late bool isCompleted;

  @HiveField(9)
  late int? noSpendDays;

  GoalModel({
    required this.id,
    required this.name,
    required this.typeIndex,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdDate,
    this.deadline,
    this.description,
    this.isCompleted = false,
    this.noSpendDays = 0,
  });

  factory GoalModel.fromEntity(Goal goal) => GoalModel(
    id: goal.id,
    name: goal.name,
    typeIndex: goal.type.index,
    targetAmount: goal.targetAmount,
    currentAmount: goal.currentAmount,
    createdDate: goal.createdDate,
    deadline: goal.deadline,
    description: goal.description,
    isCompleted: goal.isCompleted,
    noSpendDays: goal.noSpendDays,
  );

  Goal toEntity() => Goal(
    id: id,
    name: name,
    type: GoalType.values[typeIndex],
    targetAmount: targetAmount,
    currentAmount: currentAmount,
    createdDate: createdDate,
    deadline: deadline,
    description: description,
    isCompleted: isCompleted,
    noSpendDays: noSpendDays,
  );
}