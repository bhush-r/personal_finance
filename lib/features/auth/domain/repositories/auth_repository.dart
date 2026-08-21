import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream to listen for Firebase authentication changes
  Stream<UserEntity?> get authStateChanges;

  /// Returns the currently logged-in user wrapped in an Option
  Future<Option<UserEntity>> get currentUser;

  /// Sign in using email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in using Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out current user
  Future<Either<Failure, void>> signOut();
}