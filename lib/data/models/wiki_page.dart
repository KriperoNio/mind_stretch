class WikiPage {
  final int? pageid;
  final int? ns;
  final String? title;
  final String? extract;

  WikiPage({this.title, this.extract, this.pageid, this.ns});

  factory WikiPage.fromJson(Map<String, dynamic> json) {
    return WikiPage(
      pageid: json['pageid'] as int,
      ns: json['ns'] as int,
      title: json['title'] as String,
      extract: json['extract'] as String,
    );
  }
}
