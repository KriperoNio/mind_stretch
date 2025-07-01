import 'package:flutter/material.dart';
import 'package:mind_stretch/data/models/riddle_model.dart';
import 'package:mind_stretch/data/models/wikipedia/responce_model.dart';
import 'package:mind_stretch/logic/scopes/app_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository {
  final SharedPreferences prefs;

  const StorageRepository({required this.prefs});

  String? getArticle(String key) => prefs.getString('article_$key');
  String? getRiddle(String key) => prefs.getString('riddle_$key');
  String? getWord(String key) => prefs.getString('word_$key');

  Future<Riddle> loadRiddle({
    required BuildContext context,
    required String key,
  }) async {
    final cachedRiddle = getRiddle(key);
    if (cachedRiddle != null && cachedRiddle.isNotEmpty) {
      return Riddle.fromString(cachedRiddle);
    }

    try {
      final newRiddle = await AppScope.managerOf(
        context,
      ).getDeepseekRepository.generate(type: 'riddle');
      await prefs.setString('riddle_$key', newRiddle);
      return Riddle.fromString(newRiddle);
    } catch (e) {
      throw '>>> Failed to load riddle: ${e.toString()}';
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

  Future<WikiPage> loadArticle({
    required BuildContext context,
    required String key,
  }) async {
    final cachedArticle = getArticle(key);
    if (cachedArticle != null && cachedArticle.isNotEmpty) {
      return await AppScope.managerOf(
        context,
      ).getWikipediaRepository.getArticleFromTitle(title: cachedArticle);
    }

    try {
      final title = await AppScope.managerOf(
        context,
      ).getDeepseekRepository.generate(type: 'article');

      final newArticle = await AppScope.managerOf(
        context,
      ).getWikipediaRepository.getArticleFromTitle(title: title);

      await prefs.setString('article_$key', newArticle.title);
      return newArticle;
    } catch (e) {
      throw '>>> Failed to load article: ${e.toString()}';
    }
  }
}
