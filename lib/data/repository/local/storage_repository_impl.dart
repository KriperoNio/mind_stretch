import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepositoryImpl implements StorageRepository {
  final Future<SharedPreferences> prefs;

  const StorageRepositoryImpl({required this.prefs});

  static const String _titleArticleKey = 'title_article';
  static const String _currentDate = 'current_day';
  static const String _riddleKey = 'riddle';
  static const String _wordKey = 'word';

  @override
  Future<Riddle?> loadRiddle() async {
    final riddle = (await prefs).getString(_riddleKey);
    return riddle != null ? Riddle.fromString(riddle) : null;
  }

  @override
  Future<void> saveRiddle({required String riddle}) async {
    (await prefs).setString(_riddleKey, riddle);
  }

  @override
  Future<String?> loadTitleArticle() async =>
      (await prefs).getString(_titleArticleKey);

  @override
  Future<void> saveTitleArticle({required String titleArticle}) async {
    (await prefs).setString(_titleArticleKey, titleArticle);
  }

  @override
  Future<String?> loadWord() async => (await prefs).getString(_wordKey);

  @override
  Future<void> saveWord({required String word}) async {
    (await prefs).setString(_wordKey, word);
  }

  @override
  Future<String?> getCurrentDate() async =>
      (await prefs).getString(_currentDate);

  @override
  Future<void> setCurrentDate(String? value) async {
    (await prefs).setString(_currentDate, value!);
  }
  
  @override
  Future<void> resetAll() async {
    (await prefs).remove(_titleArticleKey);
    (await prefs).remove(_riddleKey);
    (await prefs).remove(_wordKey);
  }
}
