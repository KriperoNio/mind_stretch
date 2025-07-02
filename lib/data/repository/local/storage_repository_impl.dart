import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepositoryImpl implements StorageRepository {
  final SharedPreferences prefs;

  const StorageRepositoryImpl({required this.prefs});

  String get riddleKey => 'riddle';
  String get titleArticleKey => 'title_article';
  String get wordKey => 'word';

  @override
  Riddle? loadRiddle() {
    final riddle = prefs.getString(riddleKey);
    return riddle != null ? Riddle.fromString(riddle) : null;
  }

  @override
  String? loadTitleArticle() => prefs.getString(titleArticleKey);

  @override
  String? loadWord() => prefs.getString(wordKey);

  @override
  void saveRiddle({required String riddle}) {
    prefs.setString(riddleKey, riddle);
  }

  @override
  void saveTitleArticle({required String titleArticle}) {
    prefs.setString(titleArticleKey, titleArticle);
  }

  @override
  void saveWord({required String word}) {
    prefs.setString(wordKey, word);
  }
}
