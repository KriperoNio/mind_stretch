import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepositoryImpl implements StorageRepository {
  final SharedPreferences prefs;

  const StorageRepositoryImpl({required this.prefs});

  @override
  Riddle? loadRiddle() {
    final riddle = prefs.getString('riddle');
    return riddle != null ? Riddle.fromString(riddle) : null;
  }

  @override
  String? loadTitleArticle() => prefs.getString('title_article');

  @override
  String? loadWord() => prefs.getString('word');

  @override
  void saveRiddle({required String riddle}) {
    prefs.setString('riddle', riddle);
  }

  @override
  void saveTitleArticle({required String titleArticle}) {
    prefs.setString('title_article', titleArticle);
  }

  @override
  void saveWord({required String word}) {
    prefs.setString('word', word);
  }
}
