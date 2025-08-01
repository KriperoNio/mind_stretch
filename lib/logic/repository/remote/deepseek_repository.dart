import 'package:mind_stretch/data/models/generation_model.dart';

abstract class DeepseekRepository {
  /// Возвращает тип данных в зависимости от [GenerationType]
  Future<T> generate<T>({
    required GenerationType type,
    GenerationModel? generationModel,
  });
}

/// enum [GenerationType] определяет, какой тип данных нужно сгенерировать,
/// А при вызове поможет определить тип.
enum GenerationType {
  riddle(),
  word(),
  articleTitle(),
  topicChips(),
  specificTopicPromts();

  const GenerationType();
}
