import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/models/wiki_page.dart';
import 'package:mind_stretch/logic/repository/remote/wikipedia_repository.dart';

import '../../models/wikipedia/request_model.dart';
import '../../models/wikipedia/responce_model.dart';

class WikipediaRepositoryImpl implements WikipediaRepository {
  @override
  final ApiClient apiClient;
  final String _url = 'https://ru.wikipedia.org/w/api.php';

  WikipediaRepositoryImpl({required this.apiClient});

  @override
  Future<WikiPage> getArticleFromTitle({required String title}) async {
    // Сначала найдем статьи с title и получим url
    final searchRequest = WikipediaSearchRequest(searchQuery: title);
    final searchResponse = await apiClient.wikipediaDio.get(
      _url,
      queryParameters: searchRequest.toQueryParameters(),
    );

    final searchResults = WikipediaSearchResponse.fromOpensearch(
      searchResponse,
    ).results;

    if (searchResults.isEmpty) {
      throw Exception('>>> Не найдена статья в Википедии "$title"');
    }

    final pageRequest = WikipediaPageRequest(title: title);

    final pageResponse = await apiClient.wikipediaDio.get(
      _url,
      queryParameters: pageRequest.toQueryParameters(),
    );

    final wikiPage = WikipediaPageResponse.fromJson(
      pageResponse.data,
    ).query.pages.values.first;

    return wikiPage;
  }
}
