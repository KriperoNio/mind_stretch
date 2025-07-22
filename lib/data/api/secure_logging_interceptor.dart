import 'package:dio/dio.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';

class SecureLoggingInterceptor extends Interceptor {
  String debugName;
  SecureLoggingInterceptor(this.debugName);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final safeHeaders = Map<String, dynamic>.from(options.headers);
    if (safeHeaders['Authorization'] != null) {
      safeHeaders['Authorization'] = _maskApiKey(
        safeHeaders['Authorization'] as String,
      );
    }

    final safeUri = options.uri.toString().contains('api_key=')
        ? options.uri.toString().replaceAllMapped(
            RegExp(r'api_key=([^&]+)'),
            (match) => 'api_key=*****',
          )
        : options.uri.toString();

    AppLogger.info('''
>>> Secure Request <<<
URI: $safeUri
Method: ${options.method}
Headers: $safeHeaders
Body: ${options.data}
''', name: debugName);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info('''
>>> Secure Response <<<
URI: ${response.requestOptions.uri}
Status: ${response.statusCode}
Data: ${response.data}
''', name: debugName);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('''
>>> Secure Error <<<
URI: ${err.requestOptions.uri}
Error: ${err.message}
Status: ${err.response?.statusCode}
Response: ${err.response?.data}
''', name: debugName);
    super.onError(err, handler);
  }

  String _maskApiKey(String authHeader) {
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
