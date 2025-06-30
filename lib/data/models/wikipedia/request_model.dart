class WikipediaSearchRequest {
  final String searchQuery;

  WikipediaSearchRequest({required this.searchQuery});

  Map<String, dynamic> toQueryParameters() {
    return {
      'action': 'opensearch',
      'format': 'json',
      'search': searchQuery,
      'limit': '1', // Кол-во получаемых id
      'namespace': 0,
    };
  }
}

class WikipediaArticleRequest {
  final int pageId;

  WikipediaArticleRequest({required this.pageId});

  Map<String, dynamic> toQueryParameters() {
    return {
      'action': 'query',
      'format': 'json',
      'prop': 'extracts',
      'pageids': pageId.toString(),
      'explaintext': '',
      'exintro': '',
      'utf8': '',
    };
  }
}
