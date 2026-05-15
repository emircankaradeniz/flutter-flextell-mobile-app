import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState.initial());

  final AuthRepository _authRepository;

  Future<void> hydrate() async {
    emit(const AuthState.loading());

    try {
      final session = await _authRepository.restoreSession();

      if (session == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      emit(AuthState.authenticated(session));
    } catch (error) {
      emit(AuthState.failure(error.toString()));
    }
  }

  Future<void> login() async {
    emit(const AuthState.loading());

    try {
      final session = await _authRepository.login();
      emit(AuthState.authenticated(session));
    } catch (error) {
      emit(AuthState.failure(error.toString()));
    }
  }

  Future<void> refresh() async {
    final currentSession = state.session;

    if (currentSession == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    emit(const AuthState.loading());

    try {
      final session = await _authRepository.refresh(currentSession);
      emit(AuthState.authenticated(session));
    } catch (error) {
      emit(AuthState.failure(error.toString()));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState.unauthenticated());
  }
}
