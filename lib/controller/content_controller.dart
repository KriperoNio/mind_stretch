import 'package:flutter/material.dart';
import 'package:mind_stretch/core/storage/keys/settings_key.dart';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/core/storage/sections/storage_content_section.dart';
import 'package:mind_stretch/logic/cubit/article_cubit.dart';
import 'package:mind_stretch/logic/cubit/riddle_cubit.dart';
import 'package:mind_stretch/logic/cubit/word_cubit.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';

class ContentController {
  final ArticleCubit _articleCubit;
  final RiddleCubit _riddleCubit;
  final WordCubit _wordCubit;

  final StorageRepository _storage;

  ContentController({
    required StorageRepository storage,
    required ArticleCubit articleCubit,
    required RiddleCubit riddleCubit,
    required WordCubit wordCubit,
  }) : _articleCubit = articleCubit,
       _riddleCubit = riddleCubit,
       _wordCubit = wordCubit,
       _storage = storage;

  Future<void> refreshContent({
    VoidCallback? onComplete,
    Function(Object)? onError,
  }) async {
    try {
      await Future.wait([
        _articleCubit.refresh(),
        _riddleCubit.refresh(),
        _wordCubit.refresh(),
      ]);
      onComplete?.call();
    } catch (e) {
      onError?.call(e);
    }
  }

  Future<void> resetContent({
    VoidCallback? onComplete,
    Function(Object)? onError,
  }) async {
    try {
      await Future.wait([
        _articleCubit.resetAndLoad(),
        _riddleCubit.resetAndLoad(),
        _wordCubit.resetAndLoad(),
      ]);
      onComplete?.call();
    } catch (e) {
      onError?.call(e);
    }
  }

  Future<void> resetSettings({
    VoidCallback? onComplete,
    Function(Object)? onError,
  }) async {
    try {
      await Future.wait([
        _storage.removeValue(
          StorageContentSection.titleArticle,
          StorageContentKey.settings,
        ),

        _storage.removeValue(
          StorageContentSection.riddle,
          StorageContentKey.settings,
        ),

        _storage.removeValue(
          StorageContentSection.word,
          StorageContentKey.settings,
        ),
      ]);
      onComplete?.call();
    } catch (e) {
      onError?.call(e);
    }
  }

  Future<String> loadSetting(SettingsKey key) async {
    final result = await _storage.getValue(
      key.section,
      StorageContentKey.settings,
    );
    return result ?? '';
  }

  Future<void> saveSetting(SettingsKey key, String value) async {
    await _storage.setValue(key.section, StorageContentKey.settings, value);
  }
}
