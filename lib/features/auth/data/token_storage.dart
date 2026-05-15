import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_session.dart';

class TokenStorage {
  TokenStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _idTokenKey = 'id_token';
  static const _tokenTypeKey = 'token_type';
  static const _expiresAtKey = 'expires_at';

  Future<void> save(AuthSession session) async {
    await _storage.write(key: _accessTokenKey, value: session.accessToken);
    await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
    await _storage.write(key: _idTokenKey, value: session.idToken ?? '');
    await _storage.write(key: _tokenTypeKey, value: session.tokenType ?? '');
    await _storage.write(
      key: _expiresAtKey,
      value: session.expiresAt.toIso8601String(),
    );
  }

  Future<AuthSession?> read() async {
    final accessToken = await _storage.read(key: _accessTokenKey);

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final refreshToken = await _storage.read(key: _refreshTokenKey) ?? '';
    final idToken = await _storage.read(key: _idTokenKey);
    final tokenType = await _storage.read(key: _tokenTypeKey);
    final expiresAtRaw = await _storage.read(key: _expiresAtKey);

    final expiresAt = DateTime.tryParse(expiresAtRaw ?? '') ?? DateTime.now();

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken == null || idToken.isEmpty ? null : idToken,
      tokenType: tokenType == null || tokenType.isEmpty ? null : tokenType,
      expiresAt: expiresAt,
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _idTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    await _storage.delete(key: _expiresAtKey);
  }
}
