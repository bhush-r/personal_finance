import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    final userOption = await authRepository.currentUser;

    userOption.fold(
          () => emit(const Unauthenticated()),
          (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await authRepository.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onAuthGoogleSignInRequested(
      AuthGoogleSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await authRepository.signInWithGoogle();
    result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    await authRepository.signOut();
    emit(const Unauthenticated());
  }
}