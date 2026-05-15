import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/tenant.dart';

class AccountApiException implements Exception {
  const AccountApiException({
    required this.title,
    required this.message,
    this.debugDetails,
  });

  final String title;
  final String message;
  final String? debugDetails;

  @override
  String toString() {
    return message;
  }
}

class AccountRepository {
  AccountRepository({
    required AuthRepository authRepository,
    Dio? dio,
  })  : _authRepository = authRepository,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                responseType: ResponseType.json,
              ),
            );

  final AuthRepository _authRepository;
  final Dio _dio;

  Future<List<Tenant>> fetchTenants() async {
    if (!AppConfig.hasApiConfig) {
      throw const AccountApiException(
        title: 'API ayarı eksik',
        message:
            'Flextell API base URL eksik. FLEXTELL_API_BASE_URL değerini kontrol edin.',
      );
    }

    final session = await _authRepository.getValidSession();

    if (session == null) {
      throw const AccountApiException(
        title: 'Oturum bulunamadı',
        message: 'Tenant listesini almak için önce giriş yapmalısınız.',
      );
    }

    try {
      final response = await _dio.get(
        AppConfig.accountTenantsPath,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Accept': 'application/json',
          },
        ),
      );

      final tenants = _parseTenants(response.data);

      if (tenants.isEmpty) {
        throw const AccountApiException(
          title: 'Tenant bulunamadı',
          message: 'Bu kullanıcıya bağlı tenant listesi boş döndü.',
        );
      }

      return tenants;
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on AccountApiException {
      rethrow;
    } catch (error) {
      throw AccountApiException(
        title: 'Tenant listesi alınamadı',
        message: error.toString(),
      );
    }
  }

  List<Tenant> _parseTenants(dynamic data) {
    final list = _findTenantList(data);

    if (list == null) {
      return const [];
    }

    return list
        .whereType<Map>()
        .map((item) => Tenant.fromJson(Map<String, dynamic>.from(item)))
        .where((tenant) => tenant.id.trim().isNotEmpty)
        .toList();
  }

  List<dynamic>? _findTenantList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(data);
    final directValue = map['data'] ??
        map['tenants'] ??
        map['clinics'] ??
        map['items'] ??
        map['results'];

    if (directValue is List) {
      return directValue;
    }

    if (directValue is Map) {
      final nestedMap = Map<String, dynamic>.from(directValue);
      final nestedValue = nestedMap['data'] ??
          nestedMap['tenants'] ??
          nestedMap['clinics'] ??
          nestedMap['items'] ??
          nestedMap['results'];

      if (nestedValue is List) {
        return nestedValue;
      }
    }

    return null;
  }

  AccountApiException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final responseText = responseData?.toString().toLowerCase() ?? '';

    if (statusCode == 401) {
      return AccountApiException(
        title: 'Yetkilendirme başarısız',
        message:
            'Access token geçersiz veya süresi dolmuş olabilir. Tekrar giriş yapmayı deneyin.',
        debugDetails: _debugDetails(error),
      );
    }

    if (statusCode == 403 || responseText.contains('scope')) {
      return AccountApiException(
        title: 'Tenant yetkisi eksik',
        message:
            'Tenant listesini almak için OAuth uygulamasında account:read veya tenants:read yetkileri eksik olabilir.',
        debugDetails: _debugDetails(error),
      );
    }

    if (statusCode == 404) {
      return AccountApiException(
        title: 'Tenant endpoint bulunamadı',
        message:
            'Tenant listesi endpointi bulunamadı. FLEXTELL_ACCOUNT_TENANTS_PATH değerini kontrol edin.',
        debugDetails: _debugDetails(error),
      );
    }

    if (statusCode != null) {
      return AccountApiException(
        title: 'Tenant listesi alınamadı',
        message:
            'Flextell tenant isteği HTTP $statusCode kodu ile başarısız oldu.',
        debugDetails: _debugDetails(error),
      );
    }

    return AccountApiException(
      title: 'Bağlantı hatası',
      message:
          error.message ?? 'Tenant listesi alınırken bağlantı hatası oluştu.',
      debugDetails: _debugDetails(error),
    );
  }

  String? _debugDetails(DioException error) {
    if (!kDebugMode) {
      return null;
    }

    final buffer = StringBuffer()
      ..writeln('Method: ${error.requestOptions.method}')
      ..writeln('URL: ${error.requestOptions.uri}')
      ..writeln('Status code: ${error.response?.statusCode ?? '-'}')
      ..writeln('Response body: ${error.response?.data ?? '-'}');

    return buffer.toString().trim();
  }
}
