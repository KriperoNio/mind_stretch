import 'dart:math';

import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/models/deepseek/request_model.dart';
import 'package:mind_stretch/data/models/deepseek/responce_model.dart';
import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';

class DeepseekRepositoryImpl implements DeepseekRepository {
  final ApiClient apiClient;

  const DeepseekRepositoryImpl({required this.apiClient});

  @override
  /// Генерирует запрос для deepseek в зависимости от type-а
  /// нужного результата и специфики запроса.
  Future<T> generate<T>({required GenerationType type, String? specificTopic}) async {
    final systemMessage = _getSystemMessage(type, specificTopic: specificTopic);
    final response = await _makeApiRequest(systemMessage);
    return _parseResponse<T>(response, type);
  }

  String _getSystemMessage(
    GenerationType type, {
    String? specificTopic,
  }) {
    final topicPart = specificTopic != null ? '- On the topic: $specificTopic\n' : '';

    switch (type) {
      case GenerationType.riddle:
        return 'Generate 1 perfect Russian riddle with:\n'
            '${topicPart.toString()}'
            '- Strict rhyme scheme (AABB or ABAB)\n'
            '- Correct grammar cases\n'
            '- Natural poetic meter (8-10 syllables per line)\n'
            '- No "what am I" phrases\n'
            '- Logical answer\n'
            'Format:\n'
            '[RIDDLE]\nAnswer: [ANSWER]\n\n'
            'Nothing superfluous, a riddle, an answer at the end, no'
            'translation, no headlines, nothing superfluous!'
            'Examples of GOOD riddles:\n'
            "Не лает, не кусает, а в дом не пускает.\nAnswer: замок\n\n"
            "Висит груша — нельзя скушать.\nAnswer: лампочка\n\n"
            "Сидит дед, во сто шуб одет.\nAnswer: лук";
      case GenerationType.word:
        return 'Provide 1 rare Russian word with:\n'
            '${topicPart.toString()}'
            '1. Exact meaning\n'
            '2. Etymology (origin)\n'
            '3. Usage example\n\n'
            'Example:\n'
            '**Чертог**\n'
            '- Meaning: Пышное помещение, дворец\n'
            '- Origin: От старослав. "черта" (украшение) + "ог" (место)\n'
            '- Example: "Чертоги царей поражали роскошью"';
      case GenerationType.articleTitle:
        return 'Find an interesting Wikipedia article.'
            '${topicPart.toString()}'
            'Just write the name. Nothing superfluous.'
            'Text without formatting (as you usually do in github format).'
            'Write it in Russian without parentheses.Example:\n'
            'Парадокс кошки с маслом\nЭффект Мпембы\nЭффект Лейденфроста';
    }
  }

  /// Для генерации разных ответов.
  static String get _generateSeed {
    final random = Random.secure();
    final values = List.generate(6, (_) => random.nextInt(36)); // 0-9 + A-Z
    return values
        .map((n) => n < 10 ? n.toString() : String.fromCharCode(55 + n))
        .join();
  }

  /// [temperature] - Sampling temperature between 0 and 2
  ///
  /// [maxTokens] - Maximum number of tokens to generate (1-8192)
  Future<ChatCompletionResponse> _makeApiRequest(
    String systemMessage, {
    double? temperature,
    int? maxTokens,
  }) async {
    final response = await apiClient.deepseekDio.post(
      '/chat/completions',
      data: RequestModel(
        temperature: temperature,
        maxTokens: maxTokens,
        messages: [
          Message.system(systemMessage),
          Message.user('Generate by seed #$_generateSeed'),
        ],
      ).toJson(),
    );
    return ChatCompletionResponse.fromJson(response.data);
  }

  T _parseResponse<T>(ChatCompletionResponse response, GenerationType type) {
    final content = response.content;

    switch (type) {
      case GenerationType.riddle:
        return Riddle.fromString(content) as T;
      case GenerationType.word:
        return content as T;
      case GenerationType.articleTitle:
        return content as T;
    }
  }
}
