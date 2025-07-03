import 'package:mind_stretch/data/models/riddle.dart';

abstract class StorageRepository {
  Future<String?> getCurrentDate();

  Future<void> setCurrentDate(String? value);

  Future<Riddle?> loadRiddle();

  Future<void> saveRiddle({required String riddle});

  Future<String?> loadWord();

  Future<void> saveWord({required String word});

  Future<String?> loadTitleArticle();

  Future<void> saveTitleArticle({required String titleArticle});

  Future<void> resetAll();
}
