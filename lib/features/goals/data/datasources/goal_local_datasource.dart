import 'package:hive/hive.dart';
import '../models/goal_model.dart';

abstract class GoalLocalDataSource {
  Future<List<GoalModel>> getGoals();
  Future<void> saveGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
}

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final Box<GoalModel> box;

  GoalLocalDataSourceImpl({required this.box});

  @override
  Future<List<GoalModel>> getGoals() async {
    return box.values.toList();
  }

  @override
  Future<void> saveGoal(GoalModel goal) async {
    await box.put(goal.id, goal);
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await box.put(goal.id, goal);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await box.delete(id);
  }
}
