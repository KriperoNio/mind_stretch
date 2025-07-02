import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/data/models/wiki_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageRepository {
  final SharedPreferences prefs;

  const StorageRepository({required this.prefs});

  Riddle loadRiddle({required String key});

  String? loadWord({required String key});

  WikiPage loadArticle({required String key});
}
