import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.idToken,
    this.tokenType,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String? idToken;
  final String? tokenType;

  bool get canRefresh => refreshToken.isNotEmpty;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get shouldRefresh {
    return DateTime.now().add(const Duration(seconds: 30)).isAfter(expiresAt);
  }

  int get expiresIn {
    final seconds = expiresAt.difference(DateTime.now()).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? idToken,
    String? tokenType,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      idToken: idToken ?? this.idToken,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        expiresAt,
        idToken,
        tokenType,
      ];
}
