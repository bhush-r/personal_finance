import 'package:hive/hive.dart';
import '../models/goal_model.dart';
import '../../domain/entities/goal.dart';

abstract class GoalLocalDataSource {
  Future<List<Goal>> getGoals();
  Future<Goal> addGoal(Goal goal);
  Future<Goal> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
}

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final Box<GoalModel> box;

  GoalLocalDataSourceImpl({required this.box});

  @override
  Future<List<Goal>> getGoals() async {
    final models = box.values.toList();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Goal> addGoal(Goal goal) async {
    final model = GoalModel.fromEntity(goal);
    await box.add(model);
    return goal;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final model = GoalModel.fromEntity(goal);
    final key = box.values.toList().indexWhere((m) => m.id == goal.id);
    if (key != -1) {
      await box.putAt(key, model);
    }
    return goal;
  }

  @override
  Future<void> deleteGoal(String id) async {
    final key = box.values.toList().indexWhere((m) => m.id == id);
    if (key != -1) {
      await box.deleteAt(key);
    }
  }
}