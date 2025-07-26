import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/core/storage/sections/storage_content_section.dart';
import 'package:mind_stretch/data/models/storage/content_with_settings_model.dart';
import 'package:mind_stretch/data/models/storage/settings_model.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';

class WordCubit extends Cubit<WordState> {
  final StorageRepository _storage;
  final DeepseekRepository _deepseek;

  WordCubit({
    required StorageRepository storage,
    required DeepseekRepository deepseek,
  }) : _storage = storage,
       _deepseek = deepseek,
       super(WordInitial()) {
    load();
  }

  Future<void> load({bool force = false}) async {
    emit(WordLoading());

    ContentWithSettingsModel? model = await _storage.loadModel(
      StorageContentSection.word,
    );

    String? content = force ? null : model?.content;

    if (content == null) {
      try {
        final specificTopic = model?.settings.specificTopic;

        final word = await _deepseek.generate<String>(
          type: GenerationType.word,
          specificTopic: specificTopic,
        );

        final updatedModel = ContentWithSettingsModel(
          content: word,
          settings: model?.settings ?? SettingsModel(),
        );

        await _storage.saveModel(StorageContentSection.word, updatedModel);
        model = updatedModel;
      } catch (e) {
        emit(WordError('Ошибка при генерации слова: $e', e));
        return;
      }
    }

    emit(WordLoaded(word: model!.content!, settings: model.settings));
  }

  Future<void> refresh() async {
    final current = state is WordLoaded ? state as WordLoaded : null;

    final model = await _storage.loadModel(StorageContentSection.word);

    final savedWord = model?.content;
    final savedSettings = model?.settings;

    final currentWord = current?.word;
    final currentSettings = current?.settings;

    final settingsChanged = savedSettings != currentSettings;
    final wordChanged = savedWord != currentWord;

    AppLogger.debug(
      '>>> Refresh\n'
      '${'-' * 24}\n'
      '${savedSettings?.toJson()} | ${currentSettings?.toJson()}\n'
      '$settingsChanged\n'
      '${'-' * 24}\n'
      '$savedWord | $currentWord\n'
      '$wordChanged\n',
      name: 'word_cubit\n',
    );

    if (settingsChanged) {
      try {
        final newWord = await _deepseek.generate<String>(
          type: GenerationType.word,
          specificTopic: savedSettings?.specificTopic,
        );

        final newModel = ContentWithSettingsModel(
          content: newWord,
          settings: savedSettings ?? SettingsModel(),
        );

        await _storage.saveModel(StorageContentSection.word, newModel);

        emit(WordLoaded(word: newWord, settings: newModel.settings));
      } catch (e) {
        emit(WordError('Ошибка при генерации слова при смене настроек: $e', e));
      }
    } else if (wordChanged) {
      try {
        emit(WordLoaded(word: savedWord, settings: savedSettings));
      } catch (e) {
        await resetAndLoad();
      }
    } else if (currentWord == null) {
      try {
        final newWord = await _deepseek.generate<String>(
          type: GenerationType.word,
          specificTopic: savedSettings?.specificTopic,
        );

        final newModel = ContentWithSettingsModel(
          content: newWord,
          settings: savedSettings ?? SettingsModel(),
        );

        await _storage.saveModel(StorageContentSection.word, newModel);
        emit(WordLoaded(word: newWord, settings: newModel.settings));
      } catch (e) {
        emit(WordError('Ошибка при восстановлении слова: $e', e));
      }
    }
  }

  Future<void> resetAndLoad() async {
    await _storage.removeValue(
      StorageContentSection.word,
      StorageContentKey.content,
    );
    await load(force: true);
  }
}

sealed class WordState {}

class WordInitial extends WordState {}

class WordLoading extends WordState {}

class WordLoaded extends WordState {
  final String? word;
  final SettingsModel? settings;

  WordLoaded({this.word, this.settings});
}

class WordError extends WordState {
  final String message;
  final Object? error;
  WordError(this.message, [this.error]);
}
