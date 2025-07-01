import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mind_stretch/data/models/deepseek/request_model.dart';
import 'package:mind_stretch/data/models/deepseek/responce_model.dart';
import 'package:mind_stretch/logic/api/api_client.dart';

class DeepseekRepository {
  final ApiClient _apiClient;

  DeepseekRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<String> generate({required String type}) async {
    final response = await _apiClient.deepseekDio.post(
      '/chat/completions',
      data: RequestModel(
        temperature: 1.0, // Снизил для более предсказуемых рифм
        maxTokens: 200,
        messages: [
          if (type == 'riddle')
            Message.system(
              'Generate 1 perfect Russian riddle with:\n'
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
              "Сидит дед, во сто шуб одет.\nAnswer: лук",
            )
          else if (type == 'word')
            Message.system(
              'Provide 1 rare Russian word with:\n'
              '1. Exact meaning\n'
              '2. Etymology (origin)\n'
              '3. Usage example\n\n'
              'Example:\n'
              '**Чертог**\n'
              '- Meaning: Пышное помещение, дворец\n'
              '- Origin: От старослав. "черта" (украшение) + "ог" (место)\n'
              '- Example: "Чертоги царей поражали роскошью"',
            )
          else if (type == 'article')
            Message.system(
              'Find an interesting Wikipedia article.'
              'Just write the name. Nothing superfluous.'
              'Text without formatting (as you usually do in github format).'
              'Write it in Russian without parentheses.Example:\n'
              'Парадокс кошки с маслом\nЭффект Мпембы\nЭффект Лейденфроста',
            )
          else
            throw ErrorDescription('Type not defined'),
          Message.user('#${Random().nextInt(1000)} Gen'),
        ],
      ).toJson(),
    );
    return ChatCompletionResponse.fromJson(response.data).content;
  }
}
