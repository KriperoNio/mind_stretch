class ChatCompletionResponse {
  final String id;
  final List<ChatChoice> choices;
  final int created;
  final String model;
  final String object;
  final UsageInfo usage;

  ChatCompletionResponse({
    required this.id,
    required this.choices,
    required this.created,
    required this.model,
    required this.object,
    required this.usage,
  });

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionResponse(
      id: json['id'],
      choices: (json['choices'] as List)
          .map((choice) => ChatChoice.fromJson(choice))
          .toList(),
      created: json['created'],
      model: json['model'],
      object: json['object'],
      usage: UsageInfo.fromJson(json['usage']),
    );
  }

  String get content => choices.first.message.content;
}

class ChatChoice {
  final int index;
  final ChatMessage message;
  final String finishReason;

  ChatChoice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'],
      message: ChatMessage.fromJson(json['message']),
      finishReason: json['finish_reason'],
    );
  }
}

class ChatMessage {
  final String role;
  final String content;
  final String? reasoningContent;

  ChatMessage({
    required this.role,
    required this.content,
    this.reasoningContent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
      reasoningContent: json['reasoning_content'],
    );
  }
}

class UsageInfo {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  UsageInfo({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    return UsageInfo(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}