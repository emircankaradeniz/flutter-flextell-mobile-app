import 'package:equatable/equatable.dart';

import '../domain/auth_session.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.session,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        session = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        session = null,
        errorMessage = null;

  const AuthState.authenticated(AuthSession value)
      : status = AuthStatus.authenticated,
        session = value,
        errorMessage = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        session = null,
        errorMessage = null;

  const AuthState.failure(String message)
      : status = AuthStatus.failure,
        session = null,
        errorMessage = message;

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        status,
        session,
        errorMessage,
      ];
}
