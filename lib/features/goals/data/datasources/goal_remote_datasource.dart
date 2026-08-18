import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/goal.dart';
import '../models/goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<void> syncGoals(List<Goal> goals);

  Future<List<Goal>> getGoals();

  Future<void> uploadGoal(Goal goal);

  Future<void> deleteGoal(String id);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  GoalRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  CollectionReference<Map<String, dynamic>> get _userGoals =>
      firestore
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection('goals');

  @override
  Future<void> syncGoals(List<Goal> goals) async {
    if (auth.currentUser == null) return;

    final batch = firestore.batch();

    for (final goal in goals) {
      final docRef = _userGoals.doc(goal.id);

      batch.set(
        docRef,
        GoalModel.fromEntity(goal).toFirestore(),
      );
    }

    await batch.commit();
  }

  @override
  Future<List<Goal>> getGoals() async {
    if (auth.currentUser == null) {
      return [];
    }

    final snapshot = await _userGoals.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return GoalModel.fromFirestore(data).toEntity();
    }).toList();
  }

  @override
  Future<void> uploadGoal(Goal goal) async {
    if (auth.currentUser == null) return;

    await _userGoals.doc(goal.id).set(
      GoalModel.fromEntity(goal).toFirestore(),
    );
  }

  @override
  Future<void> deleteGoal(String id) async {
    if (auth.currentUser == null) return;

    await _userGoals.doc(id).delete();
  }
}