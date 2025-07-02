import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SecureLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Маскируем API-ключ в заголовках
    final safeHeaders = Map<String, dynamic>.from(options.headers);
    if (safeHeaders['Authorization'] != null) {
      safeHeaders['Authorization'] = _maskApiKey(
        safeHeaders['Authorization'] as String,
      );
    }

    // Маскируем API-ключ в URL (если есть в query параметрах)
    final safeUri = options.uri.toString().contains('api_key=')
        ? options.uri.toString().replaceAllMapped(
            RegExp(r'api_key=([^&]+)'),
            (match) => 'api_key=*****',
          )
        : options.uri.toString();

    debugPrint('''
      >>> Secure Request <<<
      > URI: $safeUri
      > Method: ${options.method}
      > Headers: $safeHeaders
      > Body: ${options.data}
    ''');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('''
        >>> Secure Response <<<
        > Status: ${response.statusCode}
        > Data: ${response.data}
    ''');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('''
      >>> Secure Error <<<
      > URI: ${err.requestOptions.uri}
      > Error: ${err.message}
      > Status: ${err.response?.statusCode}
      > Response: ${err.response?.data}
    ''');
    super.onError(err, handler);
  }

  String _maskApiKey(String authHeader) {
    // Маскируем часть ключа после "Bearer "
    if (authHeader.startsWith('Bearer ')) {
      final key = authHeader.substring(7);
      if (key.length > 8) {
        return 'Bearer ${key.substring(0, 4)}****${key.substring(key.length - 4)}';
      }
      return 'Bearer *****';
    }
    return '*****';
  }
}
