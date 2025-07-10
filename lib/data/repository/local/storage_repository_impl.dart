import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepositoryImpl implements StorageRepository {
  final Future<SharedPreferences> _prefs;

  const StorageRepositoryImpl({required Future<SharedPreferences> prefs}) : _prefs = prefs;

  static const String _titleArticleKey = 'title_article';
  static const String _currentDate = 'current_day';
  static const String _riddleKey = 'riddle';
  static const String _wordKey = 'word';

  @override
  Future<Riddle?> loadRiddle() async {
    final riddle = (await _prefs).getString(_riddleKey);
    return riddle != null ? Riddle.fromString(riddle) : null;
  }

  @override
  Future<void> saveRiddle({required String riddle}) async {
    (await _prefs).setString(_riddleKey, riddle);
  }
  
  @override
  Future<void> resetRiddle() async {
    (await _prefs).remove(_riddleKey);
  }

  @override
  Future<String?> loadTitleArticle() async =>
      (await _prefs).getString(_titleArticleKey);

  @override
  Future<void> saveTitleArticle({required String titleArticle}) async {
    (await _prefs).setString(_titleArticleKey, titleArticle);
  }

  @override
  Future<void> resetTitleArticle() async {
    (await _prefs).remove(_titleArticleKey);
  }

  @override
  Future<String?> loadWord() async => (await _prefs).getString(_wordKey);

  @override
  Future<void> saveWord({required String word}) async {
    (await _prefs).setString(_wordKey, word);
  }

  @override
  Future<void> resetWord() async {
    (await _prefs).remove(_wordKey);
  }

  @override
  Future<String?> getCurrentDate() async =>
      (await _prefs).getString(_currentDate);

  @override
  Future<void> setCurrentDate(String? value) async {
    (await _prefs).setString(_currentDate, value!);
  }
  
  @override
  Future<void> resetContent() async {
    (await _prefs).remove(_titleArticleKey);
    (await _prefs).remove(_riddleKey);
    (await _prefs).remove(_wordKey);
  }
}
