class Riddle {
  final String? riddle;
  final String? answer;

  Riddle({this.riddle, this.answer});

  factory Riddle.fromString(String? riddleString) {
    if (riddleString != null) {
      // Разделяем строку по ключевому слову "Answer:"
      final answerParts = riddleString.split('Answer:');

      if (answerParts.length != 2) {
        throw FormatException('Invalid riddle format.');
      }

      final riddle = answerParts[0].trim();
      final answer = answerParts[1].trim();

      return Riddle(riddle: riddle, answer: answer);
    } else {
      return Riddle();
    }
  }

  @override
  String toString() {
    return 'Riddle: $riddle\nAnswer: $answer';
  }
}
