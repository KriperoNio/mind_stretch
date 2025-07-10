import 'package:flutter_bloc/flutter_bloc.dart';
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

    String? title = force ? null : await _storage.loadTitleArticle();

    if (title == null) {
      try {
        title = await _deepseek.generate<String>(
          type: GenerationType.articleTitle,
        );
        await _storage.saveTitleArticle(titleArticle: title);
      } catch (e) {
        emit(ArticleError('Ошибка при генерации заголовка: $e'));
        return;
      }
    }

    try {
      final article = await _wikipedia.getArticleFromTitle(title: title);
      emit(ArticleLoaded(title: title, article: article));
    } catch (e) {
      emit(ArticleError('Ошибка при получении статьи: $e'));
    }
  }

  Future<void> refresh() async {
    final currentState = state is ArticleLoaded
        ? state as ArticleLoaded
        : ArticleLoaded();

    String? title;

    if (currentState.title == null) {
      try {
        title = await _deepseek.generate<String>(
          type: GenerationType.articleTitle,
        );
        await _storage.saveTitleArticle(titleArticle: title);
      } catch (e) {
        emit(ArticleError('Ошибка при генерации заголовка: $e'));
        return;
      }
    }

    WikiPage? article;

    if ((currentState.article == null && currentState.title != null) ||
        title != null) {
      try {
        article = await _wikipedia.getArticleFromTitle(
          title: title ?? currentState.title!,
        );
        emit(ArticleLoaded(title: title, article: article));
      } catch (e) {
        emit(ArticleError('Ошибка при обновлении статьи: $e'));
      }
    }
  }

  Future<void> resetAndLoad() async {
    await _storage.resetTitleArticle();
    await load(force: true);
  }
}

sealed class ArticleState {}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final String? title;
  final WikiPage? article;

  ArticleLoaded({this.title, this.article});
}

class ArticleError extends ArticleState {
  final String message;
  ArticleError(this.message);
}
