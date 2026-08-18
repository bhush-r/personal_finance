import 'package:cloud_firestore/cloud_firestore.dart';
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
  late int typeIndex;

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

  /// Convert Domain Entity -> Model
  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
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
  }

  /// Convert Model -> Domain Entity
  Goal toEntity() {
    return Goal(
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

  /// Convert Firestore document -> Model
  factory GoalModel.fromFirestore(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String,
      name: map['name'] as String,
      typeIndex: (map['typeIndex'] as num).toInt(),
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      createdDate: _parseDateTime(map['createdDate'])!,
      deadline: _parseDateTime(map['deadline']),
      description: map['description'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      noSpendDays: (map['noSpendDays'] as num?)?.toInt(),
    );
  }

  /// Convert Model -> Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'typeIndex': typeIndex,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdDate': createdDate.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'description': description,
      'isCompleted': isCompleted,
      'noSpendDays': noSpendDays,
    };
  }

  /// Safely parse DateTime from Firestore.
  ///
  /// Supports both:
  /// - Firestore Timestamp
  /// - ISO 8601 String
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}