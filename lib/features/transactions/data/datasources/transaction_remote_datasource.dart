import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/transaction.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<void> syncTransactions(List<Transaction> transactions);

  Future<List<Transaction>> getTransactions();

  Future<void> uploadTransaction(Transaction transaction);

  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl
    implements TransactionRemoteDataSource {
  final firestore.FirebaseFirestore firestoreDb;
  final FirebaseAuth auth;

  TransactionRemoteDataSourceImpl({
    required this.firestoreDb,
    required this.auth,
  });

  firestore.CollectionReference<Map<String, dynamic>>
  get _userTransactions =>
      firestoreDb
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection('transactions');

  @override
  Future<void> syncTransactions(
      List<Transaction> transactions,
      ) async {
    if (auth.currentUser == null) return;

    final batch = firestoreDb.batch();

    for (final transaction in transactions) {
      final docRef = _userTransactions.doc(transaction.id);

      batch.set(
        docRef,
        TransactionModel.fromEntity(transaction).toFirestore(),
      );
    }

    await batch.commit();
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    if (auth.currentUser == null) {
      return [];
    }

    final snapshot = await _userTransactions.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return transactionModelFromFirestore(data).toEntity();
    }).toList();
  }

  @override
  Future<void> uploadTransaction(
      Transaction transaction,
      ) async {
    if (auth.currentUser == null) return;

    await _userTransactions.doc(transaction.id).set(
      TransactionModel.fromEntity(transaction).toFirestore(),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (auth.currentUser == null) return;

    await _userTransactions.doc(id).delete();
  }
}

/// Convert Firestore data into TransactionModel.
///
/// This is intentionally a top-level function instead of
/// TransactionModel.fromFirestore() because TransactionModel
/// currently does not define that factory.
TransactionModel transactionModelFromFirestore(
    Map<String, dynamic> map,
    ) {
  return TransactionModel(
    id: map['id'] as String,
    amount: (map['amount'] as num).toDouble(),
    typeIndex: (map['typeIndex'] as num).toInt(),
    categoryIndex: (map['categoryIndex'] as num).toInt(),
    date: DateTime.parse(map['date'] as String),
    note: map['note'] as String? ?? '',
  );
}

/// Convert TransactionModel into Firestore data.
extension TransactionModelFirestore on TransactionModel {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'amount': amount,
      'typeIndex': typeIndex,
      'categoryIndex': categoryIndex,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}