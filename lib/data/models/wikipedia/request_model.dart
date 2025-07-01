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
      'explaintext': true,
    };
  }
}

class WikipediaPageRequest {
  final String title;

  WikipediaPageRequest({required this.title});

  Map<String, dynamic> toQueryParameters() {
    return {
      'action': 'query',
      'format': 'json',
      'prop': 'extracts',
      'titles': title,
      'explaintext': true,
      'exintro': true,
    };
  }
}
