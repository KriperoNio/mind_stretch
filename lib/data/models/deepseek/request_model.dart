class RequestModel {
  /// Possible values: [deepseek-chat, deepseek-reasoner]
  final String model;
  
  /// If set, partial message deltas will be sent as server-sent events
  final bool? stream;
  
  /// A list of messages comprising the conversation so far
  final List<Message> messages;
  
  /// Sampling temperature between 0 and 2
  final double? temperature;
  
  /// Maximum number of tokens to generate (1-8192)
  final int? maxTokens;

  RequestModel({
    required this.messages,
    this.model = 'deepseek-chat',
    this.stream = false,
    this.temperature = 0.9, // Креативность
    this.maxTokens = 150,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': stream,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };
  }
}

class Message {
  final String content;
  final String role;

  Message({
    required this.content,
    required this.role,
  });

  factory Message.system(String content) {
    return Message(content: content, role: 'system');
  }

  factory Message.user(String content) {
    return Message(content: content, role: 'user');
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'role': role,
    };
  }
}