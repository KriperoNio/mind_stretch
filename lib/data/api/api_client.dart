import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_stretch/data/api/secure_logging_interceptor.dart';

class ApiClient {
  final Dio _deepseekDio;
  final Dio _wikipediaDio;

  /// Разделение api клиента для удобной работы с запросами,
  /// чтобы header-ы не мешали разным сервисам.
  ApiClient() : _deepseekDio = Dio(), _wikipediaDio = Dio() {
    _configureDeepseekDio();
    _configureWikipediaDio();
  }

  void _configureDeepseekDio() {
    final apiKey = dotenv.env['DEEPSEEK_API_KEY'];

    if (apiKey == null) throw Exception('>>> API_KEY не найден в .env!');

    _deepseekDio.options = BaseOptions(
      /// Замечу, что рекомендуют использовать /v1 для совместимости с OpenAI
      /// /v1 это не версия!
      /// * To be compatible with OpenAI, you can also use
      /// https://api.deepseek.com/v1 as the base_url. But
      /// note that the v1 here has NO relationship with the model's version.
      baseUrl: 'https://api.deepseek.com/v1',
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
      },
    );

    // Добавляем интерцепторы при необходимости
    _deepseekDio.interceptors.add(SecureLoggingInterceptor());
  }

  void _configureWikipediaDio() {
    _wikipediaDio.options = BaseOptions(
      baseUrl: 'https://ru.wikipedia.org/w/api.php',
      headers: {'Content-Type': 'application/json'},
    );
    _wikipediaDio.interceptors.add(SecureLoggingInterceptor());
  }

  Dio get deepseekDio => _deepseekDio;
  Dio get wikipediaDio => _wikipediaDio;
}