import 'package:flutter_appauth/flutter_appauth.dart';

import '../../../core/config/app_config.dart';
import '../domain/auth_session.dart';
import 'token_storage.dart';

class AuthRepository {
  AuthRepository({
    required TokenStorage tokenStorage,
    FlutterAppAuth? appAuth,
  })  : _tokenStorage = tokenStorage,
        _appAuth = appAuth ?? const FlutterAppAuth();

  final TokenStorage _tokenStorage;
  final FlutterAppAuth _appAuth;

  Future<AuthSession> login() async {
    _checkAuthConfig();

    final response = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        AppConfig.clientId,
        AppConfig.redirectUrl,
        clientSecret:
            AppConfig.clientSecret.isEmpty ? null : AppConfig.clientSecret,
        discoveryUrl:
            AppConfig.discoveryUrl.isEmpty ? null : AppConfig.discoveryUrl,
        issuer: AppConfig.issuer.isEmpty ? null : AppConfig.issuer,
        serviceConfiguration: _serviceConfiguration,
        scopes: AppConfig.scopes,
      ),
    );

    if (response.accessToken == null || response.accessToken!.isEmpty) {
      throw Exception('Giriş tamamlandı fakat access token alınamadı.');
    }

    final session = _mapAuthorizationResponse(response);
    await _tokenStorage.save(session);

    return session;
  }

  Future<AuthSession?> restoreSession() async {
    final session = await _tokenStorage.read();

    if (session == null) {
      return null;
    }

    if (session.shouldRefresh && session.canRefresh) {
      return refresh(session);
    }

    return session;
  }

  Future<AuthSession?> getValidSession() async {
    final session = await restoreSession();

    if (session == null) {
      return null;
    }

    if (session.shouldRefresh && session.canRefresh) {
      return refresh(session);
    }

    return session;
  }

  Future<AuthSession> refresh(AuthSession currentSession) async {
    _checkAuthConfig();

    if (!currentSession.canRefresh) {
      throw Exception('Refresh token bulunamadı. Lütfen tekrar giriş yapın.');
    }

    final response = await _appAuth.token(
      TokenRequest(
        AppConfig.clientId,
        AppConfig.redirectUrl,
        clientSecret:
            AppConfig.clientSecret.isEmpty ? null : AppConfig.clientSecret,
        discoveryUrl:
            AppConfig.discoveryUrl.isEmpty ? null : AppConfig.discoveryUrl,
        issuer: AppConfig.issuer.isEmpty ? null : AppConfig.issuer,
        serviceConfiguration: _serviceConfiguration,
        refreshToken: currentSession.refreshToken,
        scopes: AppConfig.scopes,
      ),
    );

    if (response.accessToken == null || response.accessToken!.isEmpty) {
      throw Exception('Token yenilenemedi.');
    }

    final session = _mapTokenResponse(response, currentSession.refreshToken);
    await _tokenStorage.save(session);

    return session;
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  AuthorizationServiceConfiguration? get _serviceConfiguration {
    if (!AppConfig.hasManualAuthConfig) {
      return null;
    }

    return const AuthorizationServiceConfiguration(
      authorizationEndpoint: AppConfig.authorizationEndpoint,
      tokenEndpoint: AppConfig.tokenEndpoint,
    );
  }

  AuthSession _mapAuthorizationResponse(AuthorizationTokenResponse response) {
    return AuthSession(
      accessToken: response.accessToken ?? '',
      refreshToken: response.refreshToken ?? '',
      idToken: response.idToken,
      tokenType: response.tokenType,
      expiresAt: response.accessTokenExpirationDateTime ??
          DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  AuthSession _mapTokenResponse(
      TokenResponse response, String previousRefreshToken) {
    return AuthSession(
      accessToken: response.accessToken ?? '',
      refreshToken:
          response.refreshToken == null || response.refreshToken!.isEmpty
              ? previousRefreshToken
              : response.refreshToken!,
      idToken: response.idToken,
      tokenType: response.tokenType,
      expiresAt: response.accessTokenExpirationDateTime ??
          DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  void _checkAuthConfig() {
    if (!AppConfig.hasAuthConfig) {
      throw Exception(
        'Flextell auth ayarları eksik. Client ID ile discovery/issuer veya authorization/token endpoint bilgilerini girin.',
      );
    }
  }
}
