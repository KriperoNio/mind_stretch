import 'package:mind_stretch/data/models/riddle.dart';

abstract class StorageRepository {
  Riddle? loadRiddle();

  String? loadWord();

  String? loadTitleArticle();

  void saveRiddle({required String riddle});

  void saveWord({required String word});

  void saveTitleArticle({required String titleArticle});
}
