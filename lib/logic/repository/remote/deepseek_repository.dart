abstract class DeepseekRepository {
  /// Возвращает тип данных в зависимости от [GenerationType]
  Future<T> generate<T>({required GenerationType type, String? specificTopic});
}

/// enum [GenerationType] определяет, какой тип данных нужно сгенерировать,
/// А при вызове поможет определить тип.
enum GenerationType {
  riddle(),
  word(),
  articleTitle(),
  topicChips(),
  specificTopics();

  const GenerationType();
}
