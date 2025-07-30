import 'package:mind_stretch/core/storage/section_provider.dart';

enum StorageContentSection implements SectionProvider {
  riddle('riddle'),
  word('word'),
  titleArticle('title_article'),
  currentDate('current_day'),
  topicChips('topic_chips');

  @override
  final String storageKey;
  const StorageContentSection(this.storageKey);
}
