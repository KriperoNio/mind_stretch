import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/core/storage/sections/storage_content_section.dart';
import 'package:mind_stretch/data/models/storage/content_with_settings_model.dart';
import 'package:mind_stretch/data/models/storage/settings_model.dart';
import 'package:mind_stretch/data/models/wiki_page.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';
import 'package:mind_stretch/logic/repository/remote/wikipedia_repository.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final StorageRepository _storage;
  final DeepseekRepository _deepseek;
  final WikipediaRepository _wikipedia;

  ArticleCubit({
    required StorageRepository storage,
    required DeepseekRepository deepseek,
    required WikipediaRepository wikipedia,
  }) : _storage = storage,
       _deepseek = deepseek,
       _wikipedia = wikipedia,
       super(ArticleInitial()) {
    load();
  }

  Future<void> load({bool force = false}) async {
    emit(ArticleLoading());

    ContentWithSettingsModel? model = await _storage.loadModel(
      StorageContentSection.titleArticle,
    );

    String? title = force ? null : model?.content;

    if (title == null) {
      try {
        final specificTopic = model?.settings.specificTopic;

        title = await _deepseek.generate<String>(
          type: GenerationType.articleTitle,
          specificTopic: specificTopic,
        );

        final updatedModel = ContentWithSettingsModel(
          content: title,
          settings: model?.settings ?? SettingsModel(),
        );
        await _storage.saveModel(
          StorageContentSection.titleArticle,
          updatedModel,
        );
        model = updatedModel;
      } catch (e) {
        emit(ArticleError('Ошибка при генерации заголовка: $e', e));
        return;
      }
    }

    try {
      final article = await _wikipedia.getArticleFromTitle(title: title);
      emit(
        ArticleLoaded(
          title: title,
          article: article,
          settings: model?.settings,
        ),
      );
    } catch (e) {
      emit(ArticleError('Ошибка при получении статьи: $e', e));
    }
  }

  Future<void> refresh() async {
    final current = state is ArticleLoaded ? state as ArticleLoaded : null;

    ContentWithSettingsModel? model = await _storage.loadModel(
      StorageContentSection.titleArticle,
    );

    final savedSettings = model?.settings;
    final savedTitle = model?.content;

    final currentSettings = current?.settings;
    final currentTitle = current?.title;

    final settingsChanged = savedSettings != currentSettings;
    final titleChanged = savedTitle != currentTitle;
    final articleMissing = current?.article == null;

    AppLogger.debug(
      '>>> Refresh\n'
      '${'-' * 24}\n'
      '${savedSettings?.toJson()} | ${currentSettings?.toJson()}\n'
      '$settingsChanged\n'
      '${'-' * 24}\n'
      '$savedTitle | $currentTitle\n'
      '$titleChanged\n'
      '${'-' * 24}\n'
      '$articleMissing\n',
      name: 'ArticleCubit',
    );

    if (settingsChanged) {
      try {
        final specificTopic = savedSettings?.specificTopic;

        final newTitle = await _deepseek.generate<String>(
          type: GenerationType.articleTitle,
          specificTopic: specificTopic,
        );

        final updatedModel = ContentWithSettingsModel(
          content: newTitle,
          settings: savedSettings ?? SettingsModel(),
        );

        await _storage.saveModel(
          StorageContentSection.titleArticle,
          updatedModel,
        );

        final article = await _wikipedia.getArticleFromTitle(title: newTitle);

        emit(
          ArticleLoaded(
            title: newTitle,
            article: article,
            settings: updatedModel.settings,
          ),
        );
      } catch (e) {
        emit(ArticleError('Ошибка при генерации заголовка: $e', e));
      }
    } else if (titleChanged) {
      try {
        final article = await _wikipedia.getArticleFromTitle(
          title: savedTitle!,
        );

        emit(
          ArticleLoaded(
            title: savedTitle,
            article: article,
            settings: savedSettings,
          ),
        );
      } catch (e) {
        emit(ArticleError('Ошибка при загрузке сохранённой статьи: $e', e));
      }
    } else if (articleMissing && savedTitle != null) {
      try {
        final article = await _wikipedia.getArticleFromTitle(title: savedTitle);

        emit(
          ArticleLoaded(
            title: savedTitle,
            article: article,
            settings: savedSettings,
          ),
        );
      } catch (_) {
        // Попытка генерации нового заголовка, если сохраненный невалиден
        try {
          final specificTopic = savedSettings?.specificTopic;

          final newTitle = await _deepseek.generate<String>(
            type: GenerationType.articleTitle,
            specificTopic: specificTopic,
          );

          final updatedModel = ContentWithSettingsModel(
            content: newTitle,
            settings: savedSettings ?? SettingsModel(),
          );

          await _storage.saveModel(
            StorageContentSection.titleArticle,
            updatedModel,
          );

          final article = await _wikipedia.getArticleFromTitle(title: newTitle);

          emit(
            ArticleLoaded(
              title: newTitle,
              article: article,
              settings: updatedModel.settings,
            ),
          );
        } catch (e) {
          emit(ArticleError('Ошибка при восстановлении статьи: $e', e));
        }
      }
    } else if (articleMissing && savedTitle == null) {
      try {
        final specificTopic = savedSettings?.specificTopic;

        final newTitle = await _deepseek.generate<String>(
          type: GenerationType.articleTitle,
          specificTopic: specificTopic,
        );

        final updatedModel = ContentWithSettingsModel(
          content: newTitle,
          settings: savedSettings ?? SettingsModel(),
        );

        await _storage.saveModel(
          StorageContentSection.titleArticle,
          updatedModel,
        );

        final article = await _wikipedia.getArticleFromTitle(title: newTitle);

        emit(
          ArticleLoaded(
            title: newTitle,
            article: article,
            settings: updatedModel.settings,
          ),
        );
      } catch (e) {
        emit(ArticleError('Ошибка при повтроной генерации заголовка: $e', e));
      }
    }
  }

  Future<void> resetAndLoad() async {
    await _storage.removeValue(
      StorageContentSection.titleArticle,
      StorageContentKey.content,
    );
    await load(force: true);
  }
}

sealed class ArticleState {}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final String? title;
  final WikiPage? article;
  final SettingsModel? settings;

  ArticleLoaded({this.title, this.article, this.settings});
}

class ArticleError extends ArticleState {
  final String message;
  final Object? error;
  ArticleError(this.message, [this.error]);
}
