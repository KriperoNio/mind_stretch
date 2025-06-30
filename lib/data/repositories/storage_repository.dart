import 'package:flutter/material.dart';
import 'package:mind_stretch/logic/scopes/app_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository {
  final SharedPreferences prefs;

  const StorageRepository({required this.prefs});

  String? getArticle(String key) => prefs.getString('article_$key');
  String? getRiddle(String key) => prefs.getString('riddle_$key');
  String? getWord(String key) => prefs.getString('word_$key');

  Future<String> loadRiddle({
    required BuildContext context,
    required String key,
  }) async {
    final cachedRiddle = getRiddle(key);
    if (cachedRiddle != null && cachedRiddle.isNotEmpty) return cachedRiddle;

    try {
      final newRiddle = await AppScope.managerOf(
        context,
      ).getDeepseekRepository.generate(type: 'riddle');
      await prefs.setString('riddle_$key', newRiddle);
      return newRiddle;
    } catch (e) {
      return '>>> Failed to load riddle: ${e.toString()}';
    }
  }

  Future<String> loadWord({
    required BuildContext context,
    required String key,
  }) async {
    final cachedWord = getWord(key);
    if (cachedWord != null && cachedWord.isNotEmpty) return cachedWord;

    try {
      final newWord = await AppScope.managerOf(
        context,
      ).getDeepseekRepository.generate(type: 'word');
      await prefs.setString('word_$key', newWord);
      return newWord;
    } catch (e) {
      return '>>> Failed to load word: ${e.toString()}';
    }
  }

  Future<String> loadArticle({
    required AsyncSnapshot<String> snapshot,
    required BuildContext context,
    required String key,
  }) async {
    final cachedArticle = getArticle(key);
    if (cachedArticle != null && cachedArticle.isNotEmpty) return cachedArticle;

    try {
      final regex = RegExp(r'^\*\*([^*]+)\*\*');

      final searchWord = regex.firstMatch(snapshot.data!)!.group(1)!;

      debugPrint('>>> $searchWord');

      final newArticle = await AppScope.managerOf(
        context,
      ).getWikipediaRepository.getArticleFromWord(word: searchWord);

      debugPrint('>>> $newArticle');

      await prefs.setString('article_$key', newArticle);
      return newArticle;
    } catch (e) {
      return '>>> Failed to load article: ${e.toString()}';
    }
  }
}
