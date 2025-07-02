import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/models/riddle.dart';

abstract class DeepseekRepository {
  final ApiClient apiClient;

  const DeepseekRepository({required this.apiClient});

  /// Возвращает тип данных в зависимости от [GenerationType]
  Future<T> generate<T>({required GenerationType type});
}

/// enum [GenerationType] определяет, какой тип данных нужно сгенерировать.
enum GenerationType {
  riddle(responce: Riddle),
  word(responce: String),
  articleTitle(responce: String);

  final Type responce;

  const GenerationType({required this.responce});
}
