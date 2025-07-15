import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StorageContentKey {
  riddle('riddle'),
  word('word'),
  titleArticle('title_article'),
  currentDate('current_day');

  final String key;
  const StorageContentKey(this.key);
}

enum SettingsContentKey {
  riddle('riddle_settings'),
  word('word_settings'),
  titleArticle('title_article_settings'),
  currentDate('current_day_settings');

  final String key;
  const SettingsContentKey(this.key);
}

class StorageRepositoryImpl implements StorageRepository {
  final Future<SharedPreferences> _prefs;

  const StorageRepositoryImpl({required Future<SharedPreferences> prefs}) : _prefs = prefs;

  @override
  Future<String?> load(String key) async {
    return (await _prefs).getString(key);
  }

  @override
  Future<void> save(String key, String value) async {
    await (await _prefs).setString(key, value);
  }

  @override
  Future<void> reset(String key) async {
    await (await _prefs).remove(key);
  }

  @override
  Future<void> resetAll() async {
    await (await _prefs).clear();
  }
}
