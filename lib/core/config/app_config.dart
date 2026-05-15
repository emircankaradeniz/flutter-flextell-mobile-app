class AppConfig {
  static const clientId = String.fromEnvironment('FLEXTELL_CLIENT_ID');

  static const clientSecret = String.fromEnvironment('FLEXTELL_CLIENT_SECRET');

  static const redirectUrl = String.fromEnvironment(
    'FLEXTELL_REDIRECT_URL',
    defaultValue: 'com.example.flextellcase://oauth-callback',
  );

  static const discoveryUrl = String.fromEnvironment('FLEXTELL_DISCOVERY_URL');

  static const issuer = String.fromEnvironment('FLEXTELL_ISSUER');

  static const authorizationEndpoint = String.fromEnvironment(
    'FLEXTELL_AUTHORIZATION_ENDPOINT',
    defaultValue: 'https://dev.flextell.ai/oauth/authorize',
  );

  static const tokenEndpoint = String.fromEnvironment(
    'FLEXTELL_TOKEN_ENDPOINT',
    defaultValue: 'https://dev.flextell.ai/oauth/token',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'FLEXTELL_API_BASE_URL',
    defaultValue: 'https://dev.flextell.ai',
  );

  static const accountTenantsPath = String.fromEnvironment(
    'FLEXTELL_ACCOUNT_TENANTS_PATH',
    defaultValue: '/api/v1/account/tenants',
  );

  static const customersPath = String.fromEnvironment(
    'FLEXTELL_CUSTOMERS_PATH',
    defaultValue: '/api/v1/customers',
  );

  static const tenant = String.fromEnvironment('FLEXTELL_TENANT');

  static const tenantHeaderName = String.fromEnvironment(
    'FLEXTELL_TENANT_HEADER',
    defaultValue: 'X-Tenant',
  );

  static const scopesRaw = String.fromEnvironment(
    'FLEXTELL_SCOPES',
    defaultValue: 'customers:read',
  );

  static List<String> get scopes {
    return scopesRaw
        .split(RegExp(r'[\s,]+'))
        .where((scope) => scope.trim().isNotEmpty)
        .toList();
  }

  static bool get hasDiscoveryConfig {
    return discoveryUrl.isNotEmpty || issuer.isNotEmpty;
  }

  static bool get hasManualAuthConfig {
    return authorizationEndpoint.isNotEmpty && tokenEndpoint.isNotEmpty;
  }

  static bool get hasAuthConfig {
    return clientId.isNotEmpty && (hasDiscoveryConfig || hasManualAuthConfig);
  }

  static bool get hasApiConfig {
    return apiBaseUrl.isNotEmpty;
  }

  static bool get hasManualTenant {
    return tenant.trim().isNotEmpty;
  }
}
