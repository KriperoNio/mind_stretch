import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_stretch/logic/api/secure_logging_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _configureDio();
  }

  void _configureDio() {
    // Да, можно было реализовать токином и сделать dart файл. 
    // Даже лучше будет...
    final apiKey = dotenv.env['DEEPSEEK_API_KEY'];

    if (apiKey == null) throw Exception('>>> API_KEY не найден в .env!');

    _dio.options = BaseOptions(
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
    dio.interceptors.add(SecureLoggingInterceptor());
  }

  Dio get dio => _dio;
}
