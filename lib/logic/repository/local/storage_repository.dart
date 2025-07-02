import 'package:mind_stretch/data/models/riddle.dart';

abstract class StorageRepository {
  String? get currentDate;

  Riddle? loadRiddle();

  String? loadWord();

  String? loadTitleArticle();

  set currentDate(String? value);

  void saveRiddle({required String riddle});

  void saveWord({required String word});

  void saveTitleArticle({required String titleArticle});
  
}
