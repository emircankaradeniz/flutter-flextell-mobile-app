import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/customer.dart';

class CustomersApiException implements Exception {
  const CustomersApiException({
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

class CustomersRepository {
  CustomersRepository({
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

  Future<List<Customer>> fetchCustomers({
    required String tenantId,
  }) async {
    if (!AppConfig.hasApiConfig) {
      throw const CustomersApiException(
        title: 'API ayarı eksik',
        message:
            'Flextell API base URL eksik. FLEXTELL_API_BASE_URL değerini kontrol edin.',
      );
    }

    if (tenantId.trim().isEmpty) {
      throw const CustomersApiException(
        title: 'Tenant seçilmedi',
        message:
            'Müşteri listesini almak için geçerli bir tenant seçilmelidir.',
      );
    }

    final session = await _authRepository.getValidSession();

    if (session == null) {
      throw const CustomersApiException(
        title: 'Oturum bulunamadı',
        message: 'Müşteri listesini görmek için önce giriş yapmalısınız.',
      );
    }

    try {
      final response = await _dio.get(
        AppConfig.customersPath,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Accept': 'application/json',
            AppConfig.tenantHeaderName: tenantId,
          },
        ),
      );

      return _parseCustomers(response.data);
    } on DioException catch (error) {
      throw _mapDioError(error, tenantId);
    } on CustomersApiException {
      rethrow;
    } catch (error) {
      throw CustomersApiException(
        title: 'Müşteri listesi okunamadı',
        message: error.toString(),
      );
    }
  }

  List<Customer> _parseCustomers(dynamic data) {
    final list = _findCustomerList(data);

    if (list != null) {
      return list
          .whereType<Map>()
          .map((item) => Customer.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (_looksLikeCustomer(map)) {
        return [Customer.fromJson(map)];
      }
    }

    throw const CustomersApiException(
      title: 'Beklenmeyen cevap formatı',
      message:
          'API isteği başarılı oldu fakat müşteri listesi beklenen formatta dönmedi.',
    );
  }

  List<dynamic>? _findCustomerList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(data);
    final directValue = map['data'] ??
        map['customers'] ??
        map['items'] ??
        map['results'] ??
        map['records'];

    if (directValue is List) {
      return directValue;
    }

    if (directValue is Map) {
      final nestedMap = Map<String, dynamic>.from(directValue);
      final nestedValue = nestedMap['data'] ??
          nestedMap['customers'] ??
          nestedMap['items'] ??
          nestedMap['results'] ??
          nestedMap['records'];

      if (nestedValue is List) {
        return nestedValue;
      }
    }

    return null;
  }

  bool _looksLikeCustomer(Map<String, dynamic> map) {
    return map.containsKey('id') ||
        map.containsKey('_id') ||
        map.containsKey('customerId') ||
        map.containsKey('customer_id');
  }

  CustomersApiException _mapDioError(DioException error, String tenantId) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final responseText = responseData?.toString().toLowerCase() ?? '';

    if (responseText.contains('tenant')) {
      return CustomersApiException(
        title: 'Tenant bilgisi hatalı',
        message:
            'Flextell API seçilen tenant ile müşteri listesini döndürmedi. Tenant ID: $tenantId',
        debugDetails: _debugDetails(error, tenantId),
      );
    }

    if (statusCode == 401) {
      return CustomersApiException(
        title: 'Yetkilendirme başarısız',
        message:
            'Access token geçersiz veya süresi dolmuş olabilir. Tekrar giriş yapmayı deneyin.',
        debugDetails: _debugDetails(error, tenantId),
      );
    }

    if (statusCode == 403) {
      return CustomersApiException(
        title: 'Yetki yetersiz',
        message:
            'Bu token müşteri listesini okumaya yetkili görünmüyor. OAuth uygulamasında customers:read yetkisini kontrol edin.',
        debugDetails: _debugDetails(error, tenantId),
      );
    }

    if (statusCode == 404) {
      return CustomersApiException(
        title: 'Endpoint veya tenant bulunamadı',
        message:
            'Customers endpoint veya seçilen tenant bulunamadı. Endpoint ve tenant ID değerini kontrol edin.',
        debugDetails: _debugDetails(error, tenantId),
      );
    }

    if (statusCode != null) {
      return CustomersApiException(
        title: 'API isteği başarısız oldu',
        message:
            'Flextell API isteği HTTP $statusCode kodu ile başarısız oldu.',
        debugDetails: _debugDetails(error, tenantId),
      );
    }

    return CustomersApiException(
      title: 'Bağlantı hatası',
      message: error.message ??
          'Flextell API isteği sırasında bağlantı hatası oluştu.',
      debugDetails: _debugDetails(error, tenantId),
    );
  }

  String? _debugDetails(DioException error, String tenantId) {
    if (!kDebugMode) {
      return null;
    }

    final buffer = StringBuffer()
      ..writeln('Method: ${error.requestOptions.method}')
      ..writeln('URL: ${error.requestOptions.uri}')
      ..writeln('Status code: ${error.response?.statusCode ?? '-'}')
      ..writeln('Tenant header: ${AppConfig.tenantHeaderName}')
      ..writeln('Tenant value: $tenantId')
      ..writeln('Response body: ${error.response?.data ?? '-'}');

    return buffer.toString().trim();
  }
}
