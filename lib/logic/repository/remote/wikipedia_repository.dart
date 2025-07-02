import 'package:mind_stretch/data/models/wiki_page.dart';

abstract class WikipediaRepository {
  /// Выдает [WikiPage] в зависимости от найденной статьи
  /// по заголовку.
  Future<WikiPage> getArticleFromTitle({required String title});
}
