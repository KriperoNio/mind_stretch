class WikipediaSearchResponse {
  final List<WikipediaSearchResult> results;

  WikipediaSearchResponse({required this.results});

  factory WikipediaSearchResponse.fromJson(Map<String, dynamic> json) {
    final query = json['query'] as Map<String, dynamic>;
    final search = query['search'] as List<dynamic>;

    return WikipediaSearchResponse(
      results: search
          .map((result) => WikipediaSearchResult.fromJson(result))
          .toList(),
    );
  }
}

class WikipediaArticleResponse {
  final int pageId;
  final String title;
  final String extract;

  WikipediaArticleResponse({
    required this.pageId,
    required this.title,
    required this.extract,
  });

  factory WikipediaArticleResponse.fromJson(Map<String, dynamic> json) {
    final query = json['query'] as Map<String, dynamic>;
    final pages = query['pages'] as Map<String, dynamic>;
    final page = pages.values.first as Map<String, dynamic>;

    return WikipediaArticleResponse(
      pageId: page['pageid'],
      title: page['title'],
      extract: page['extract'],
    );
  }
}

class WikipediaSearchResult {
  final int pageId;
  final String title;
  final String snippet;

  WikipediaSearchResult({
    required this.pageId,
    required this.title,
    required this.snippet,
  });

  factory WikipediaSearchResult.fromJson(Map<String, dynamic> json) {
    return WikipediaSearchResult(
      pageId: json['pageid'],
      title: json['title'],
      snippet: json['snippet'],
    );
  }
}
