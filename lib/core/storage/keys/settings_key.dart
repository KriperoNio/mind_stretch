import 'package:mind_stretch/core/storage/section_provider.dart';
import 'package:mind_stretch/core/storage/sections/storage_content_section.dart';

enum SettingsKey {
  article,
  riddle,
  word;

  SectionProvider get section {
    switch (this) {
      case SettingsKey.article:
        return StorageContentSection.titleArticle;
      case SettingsKey.riddle:
        return StorageContentSection.riddle;
      case SettingsKey.word:
        return StorageContentSection.word;
    }
  }

  String get label {
    switch (this) {
      case SettingsKey.article:
        return 'Статья';
      case SettingsKey.riddle:
        return 'Загадка';
      case SettingsKey.word:
        return 'Слово';
    }
  }
}
