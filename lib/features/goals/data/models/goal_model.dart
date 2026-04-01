import 'package:hive/hive.dart';
import '../../domain/entities/goal.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 1)
class GoalModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late int typeIndex;

  @HiveField(3)
  late double targetAmount;

  @HiveField(4)
  late double currentAmount;

  @HiveField(5)
  DateTime? deadline;

  @HiveField(6)
  late int streakDays;

  @HiveField(7)
  String? category;

  GoalModel({
    required this.id,
    required this.title,
    required this.typeIndex,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.streakDays,
    this.category,
  });

  factory GoalModel.fromEntity(Goal goal) => GoalModel(
        id: goal.id,
        title: goal.title,
        typeIndex: goal.type.index,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        deadline: goal.deadline,
        streakDays: goal.streakDays,
        category: goal.category,
      );

  Goal toEntity() => Goal(
        id: id,
        title: title,
        type: GoalType.values[typeIndex],
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: deadline,
        streakDays: streakDays,
        category: category,
      );
}
