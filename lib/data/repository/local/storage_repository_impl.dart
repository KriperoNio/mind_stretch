import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepositoryImpl implements StorageRepository {
  final SharedPreferences prefs;

  const StorageRepositoryImpl({required this.prefs});

  static const String _riddleKey = 'riddle';
  static const String _titleArticleKey = 'title_article';
  static const String _wordKey = 'word';
  static const String _currentDay = 'current_day';

  @override
  String get currentDate => prefs.getString(_currentDay) ?? '';

  @override
  set currentDate(String? value) {
    prefs.setString(_currentDay, value!);
  }

  @override
  Riddle? loadRiddle() {
    final riddle = prefs.getString(_riddleKey);
    return riddle != null ? Riddle.fromString(riddle) : null;
  }

  @override
  void saveRiddle({required String riddle}) {
    prefs.setString(_riddleKey, riddle);
  }

  @override
  String? loadTitleArticle() => prefs.getString(_titleArticleKey);

  @override
  void saveTitleArticle({required String titleArticle}) {
    prefs.setString(_titleArticleKey, titleArticle);
  }

  @override
  String? loadWord() => prefs.getString(_wordKey);

  @override
  void saveWord({required String word}) {
    prefs.setString(_wordKey, word);
  }
}
