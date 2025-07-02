import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/data/models/wiki_page.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepositoryImpl implements StorageRepository {
  @override
  final SharedPreferences prefs;

  const StorageRepositoryImpl({required this.prefs});

  @override
  Riddle loadRiddle({required String key}) =>
      Riddle.fromString(prefs.getString(key));

  @override
  WikiPage loadArticle({required String key}) =>
      WikiPage(title: prefs.getString(key));

  @override
  String? loadWord({required String key}) => prefs.getString(key);
}
