import 'package:flutter/material.dart';
import 'package:mind_stretch/data/repositories/deepseek_repository.dart';
import 'package:mind_stretch/data/repositories/storage_repository.dart';
import 'package:mind_stretch/data/repositories/wikipedia_repository.dart';
import 'package:mind_stretch/logic/api/api_client.dart';
import 'package:mind_stretch/logic/notifiers/day_value_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppManager extends ChangeNotifier {
  final WikipediaRepository _wikipediaRepository;
  final DeepseekRepository _deepseekRepository;
  final StorageRepository _storageRepository;
  final DayValueNotifier _dayValueNotifier;
  final SharedPreferences _preferences;
  final ApiClient _apiClient;

  AppManager({
    required WikipediaRepository wikipediaRepository,
    required DeepseekRepository deepseekRepository,
    required StorageRepository storageRepository,
    required DayValueNotifier dayValueNotifier,
    required SharedPreferences preferences,
    required ApiClient apiClient,
  }) : _wikipediaRepository = wikipediaRepository,
       _deepseekRepository = deepseekRepository,
       _storageRepository = storageRepository,
       _dayValueNotifier = dayValueNotifier,
       _preferences = preferences,
       _apiClient = apiClient;

  WikipediaRepository get getWikipediaRepository => _wikipediaRepository;

  DeepseekRepository get getDeepseekRepository => _deepseekRepository;

  StorageRepository get getStorageRepository => _storageRepository;

  DayValueNotifier get getDayValueNotifier => _dayValueNotifier;

  SharedPreferences get getPreferences => _preferences;

  ApiClient get getApiClient => _apiClient;
}
