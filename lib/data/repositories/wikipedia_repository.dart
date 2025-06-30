import 'package:mind_stretch/data/models/wikipedia/request_model.dart';
import 'package:mind_stretch/data/models/wikipedia/responce_model.dart';
import 'package:mind_stretch/logic/api/api_client.dart';

class WikipediaRepository {
  final ApiClient _apiClient;
  final String _url = 'https://ru.wikipedia.org/w/api.php';

  WikipediaRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<String> getArticleFromWord({required String word}) async {
    // Сначала найдем статьи с word и получим id
    final searchRequest = WikipediaSearchRequest(searchQuery: word);
    final searchResponse = await _apiClient.dio.get(
      _url,
      queryParameters: searchRequest.toQueryParameters(),
    );

    final searchResults = WikipediaSearchResponse.fromJson(
      searchResponse.data,
    ).results;

    if (searchResults.isEmpty) {
      throw Exception('>>> Не найдена статья в Википедии "$word"');
    }

    // Затем извлечем содержимое статьи по id
    final articleRequest = WikipediaArticleRequest(
      pageId: searchResults.first.pageId,
    );
    final articleResponse = await _apiClient.dio.get(
      _url,
      queryParameters: articleRequest.toQueryParameters(),
    );

    return WikipediaArticleResponse.fromJson(articleResponse.data).extract;
  }
}
