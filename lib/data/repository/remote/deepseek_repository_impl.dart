import 'dart:convert';
import 'dart:math';

import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/models/deepseek/request_model.dart';
import 'package:mind_stretch/data/models/deepseek/responce_model.dart';
import 'package:mind_stretch/data/models/generation_model.dart';
import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';

class DeepseekRepositoryImpl implements DeepseekRepository {
  final ApiClient apiClient;

  const DeepseekRepositoryImpl({required this.apiClient});

  @override
  /// Генерирует запрос для deepseek в зависимости от type-а
  /// нужного результата и специфики запроса.
  Future<T> generate<T>({
    required GenerationType type,
    GenerationModel? generationModel,
  }) async {
    final systemMessage = _getSystemMessage(
      type,
      generationModel: generationModel,
    );
    final response = await _makeApiRequest(systemMessage);
    return _parseResponse<T>(response, type);
  }

  String _getSystemMessage(
    GenerationType type, {
    GenerationModel? generationModel,
  }) {
    final topicPart = generationModel?.specificTopic != null
        ? '- On the topic: ${generationModel?.specificTopic}\n'
        : '';

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
      case GenerationType.topicChips:
        return 'Come up with a list of 32 different topics (for example, '
            'science, art, sports), formalize each item in the format of "Name 🎨",'
            ', where 🎨 is a suitable smiley face for a phone device. Make the list'
            'diverse and interesting. An example of your response to me (dart: List<String>)'
            '["Culture 🖼", "History 📜", "Technique 💻"], for further parsing.'
            "Don't add anything superfluous, just a list, without your comments.";
      case GenerationType.specificTopicPromts:
        return 'Create a special request theme for generating Russian-language content based on the keys listed '
            'in `forAPart`. Use the variable `specificTopic` as contextual input for the theme.'
            'Return the result strictly as a Dart map (`Map<String, String>`) with each key from `forAPart` '
            'mapped to a short and relevant Russian-language theme for request.'
            'Variables:\n'
            '- forAPart: ${generationModel?.forA} — List<String> list of content types to generate themes for, e.g. ["riddle", "word"]'
            '- specificTopic: ${generationModel?.specificTopic} — String contextual subject to focus the themes around.'
            'Example request variables:\n'
            '- forAPart: ["article", "word"]'
            '- specificTopic: Квантовая физика'
            'for this Example response format:\n'
            '{"article": "Квантовая физика и загадки настоящего", "word": "Научный термин из квантовой физики"}'
            'If forAPart = ["riddle"], expected output:\n'
            '{"riddle": "Летние послания"}'
            '⚠ Output only the Dart map, without any additional explanations or formatting.';
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
      case GenerationType.word:
      case GenerationType.articleTitle:
        return content as T;
      case GenerationType.riddle:
        return Riddle.fromString(content) as T;
      case GenerationType.topicChips:
        final decoded = jsonDecode(content) as List<dynamic>;
        return decoded.cast<String>() as T;
      case GenerationType.specificTopicPromts:
        final decoded = jsonDecode(content) as Map<String, String>;
        return decoded.cast<String, String>() as T;
    }
  }
}
