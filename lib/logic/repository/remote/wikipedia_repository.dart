import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/models/wiki_page.dart';

abstract class WikipediaRepository {
  final ApiClient apiClient;

  WikipediaRepository({required this.apiClient});

  Future<WikiPage> getArticleFromTitle({required String title});
}
