import 'package:dio/dio.dart';

class WikipediaSearchResponse {
  final List<WikipediaSearchResult> results;

  WikipediaSearchResponse({required this.results});

  factory WikipediaSearchResponse.fromOpensearch(Response<dynamic> response) {
    // Ответ от action=opensearch приходит в формате List<dynamic>
    final data = response.data as List<dynamic>;

    // Структура ответа opensearch:
    // [searchTerm, [titles], [descriptions], [urls]]
    final titles = data[1] as List<dynamic>;
    final descriptions = data[2] as List<dynamic>;
    final urls = data[3] as List<dynamic>;

    final results = <WikipediaSearchResult>[];

    for (var i = 0; i < titles.length; i++) {
      results.add(
        WikipediaSearchResult(
          title: titles[i] as String,
          description: i < descriptions.length ? descriptions[i] as String : '',
          url: i < urls.length ? urls[i] as String : '',
        ),
      );
    }

    return WikipediaSearchResponse(results: results);
  }
}

class WikipediaSearchResult {
  final String title;
  final String description;
  final String url;

  WikipediaSearchResult({
    required this.title,
    required this.description,
    required this.url,
  });
}

class WikipediaPageResponse {
  final String batchcomplete;
  final Query query;

  WikipediaPageResponse({
    required this.batchcomplete,
    required this.query,
  });

  factory WikipediaPageResponse.fromJson(Map<String, dynamic> json) {
    return WikipediaPageResponse(
      batchcomplete: json['batchcomplete'] as String,
      query: Query.fromJson(json['query'] as Map<String, dynamic>),
    );
  }
}

class Query {
  final Map<String, WikiPage> pages;

  Query({required this.pages});

  factory Query.fromJson(Map<String, dynamic> json) {
    final pagesMap = <String, WikiPage>{};
    final pagesJson = json['pages'] as Map<String, dynamic>;
    
    pagesJson.forEach((key, value) {
      pagesMap[key] = WikiPage.fromJson(value as Map<String, dynamic>);
    });

    return Query(pages: pagesMap);
  }
}

class WikiPage {
  final int pageid;
  final int ns;
  final String title;
  final String extract;

  WikiPage({
    required this.pageid,
    required this.ns,
    required this.title,
    required this.extract,
  });

  factory WikiPage.fromJson(Map<String, dynamic> json) {
    return WikiPage(
      pageid: json['pageid'] as int,
      ns: json['ns'] as int,
      title: json['title'] as String,
      extract: json['extract'] as String,
    );
  }
}