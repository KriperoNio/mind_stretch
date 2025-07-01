import 'package:mind_stretch/data/models/wikipedia/request_model.dart';
import 'package:mind_stretch/data/models/wikipedia/responce_model.dart';
import 'package:mind_stretch/logic/api/api_client.dart';

class WikipediaRepository {
  final ApiClient _apiClient;
  final String _url = 'https://ru.wikipedia.org/w/api.php';

  WikipediaRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<WikiPage> getArticleFromTitle({required String title}) async {
    // Сначала найдем статьи с title и получим url
    final searchRequest = WikipediaSearchRequest(searchQuery: title);
    final searchResponse = await _apiClient.wikipediaDio.get(
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

    final pageResponse = await _apiClient.wikipediaDio.get(
      _url,
      queryParameters: pageRequest.toQueryParameters(),
    );

    final pageResults = WikipediaPageResponse.fromJson(
      pageResponse.data,
    ).query.pages.values.first;

    return pageResults;
  }
}
