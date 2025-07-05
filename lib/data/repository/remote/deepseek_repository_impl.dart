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
  /// нужного результата.
  Future<T> generate<T>({required GenerationType type}) async {
    final systemMessage = _getSystemMessage(type);
    final response = await _makeApiRequest(systemMessage);
    return _parseResponse<T>(response, type);
  }

  String _getSystemMessage(GenerationType type) {
    switch (type) {
      case GenerationType.riddle:
        return 'Generate 1 perfect Russian riddle with:\n'
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
            'Just write the name. Nothing superfluous.'
            'Text without formatting (as you usually do in github format).'
            'Write it in Russian without parentheses.Example:\n'
            'Парадокс кошки с маслом\nЭффект Мпембы\nЭффект Лейденфроста';
    }
  }

  Future<ChatCompletionResponse> _makeApiRequest(String systemMessage) async {
    final response = await apiClient.deepseekDio.post(
      '/chat/completions',
      data: RequestModel(
        temperature: 1.0,
        maxTokens: 200,
        messages: [
          Message.system(systemMessage),
          Message.user('#${Random().nextInt(1000)} Gen'),
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
