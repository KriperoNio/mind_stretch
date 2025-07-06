import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/data/models/wiki_page.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';
import 'package:mind_stretch/logic/repository/remote/wikipedia_repository.dart';

class DailyContentBloc extends Bloc<DailyContentEvent, DailyContentState> {
  late final Timer _dayCheckTimer;

  final StorageRepository _storageRepository;
  final DeepseekRepository _deepseekRepository;
  final WikipediaRepository _wikipediaRepository;

  DateTime _lastDay = DateTime.now();

  DailyContentBloc({
    required StorageRepository storageRepository,
    required DeepseekRepository deepseekRepository,
    required WikipediaRepository wikipediaRepository,
  }) : _storageRepository = storageRepository,
       _deepseekRepository = deepseekRepository,
       _wikipediaRepository = wikipediaRepository,
       super(DailyContentLoading()) {
    on<DailyContentCheckAndLoad>(_onCheckAndLoad);
    on<DailyContentForceReset>(_onForceReset);
    on<DailyContentRefresh>(_onRefresh);

    _dayCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.day != _lastDay.day ||
          now.month != _lastDay.month ||
          now.year != _lastDay.year) {
        _lastDay = now;
        add(DailyContentCheckAndLoad());
      }
    });
  }

  @override
  Future<void> close() {
    _dayCheckTimer.cancel();
    return super.close();
  }

  Future<void> _generateAndSaveContent(
    Emitter<DailyContentState> emit, {
    bool reGenerate = false,
  }) async {
    final currentContent = state is DailyContentLoaded
        ? state as DailyContentLoaded
        : DailyContentLoaded();

    if (reGenerate) {
      await _storageRepository.resetAll();
    }

    Future<Riddle?> riddleFuture() async {
      if (!reGenerate && currentContent.riddle != null) {
        return currentContent.riddle;
      }
      try {
        final riddle = await _deepseekRepository.generate<Riddle>(
          type: GenerationType.riddle,
        );
        await _storageRepository.saveRiddle(riddle: riddle.toString());
        return riddle;
      } catch (e) {
        debugPrint('>>> Ошибка при генерации загадки: $e');
        return null;
      }
    }

    Future<String?> wordFuture() async {
      if (!reGenerate && currentContent.word != null) {
        return currentContent.word;
      }
      try {
        final word = await _deepseekRepository.generate<String>(
          type: GenerationType.word,
        );
        await _storageRepository.saveWord(word: word);
        return word;
      } catch (e) {
        debugPrint('>>> Ошибка при генерации слова: $e');
        return null;
      }
    }

    Future<(String?, WikiPage?)> articleFuture() async {
      if (!reGenerate &&
          currentContent.titleArticle != null &&
          currentContent.article != null) {
        return (currentContent.titleArticle, currentContent.article);
      }
      try {
        final title = await _deepseekRepository.generate<String>(
          type: GenerationType.articleTitle,
        );
        final article = await _wikipediaRepository.getArticleFromTitle(
          title: title,
        );
        await _storageRepository.saveTitleArticle(titleArticle: title);
        return (title, article);
      } catch (e) {
        debugPrint('>>> Ошибка при генерации статьи: $e');
        return (null, null);
      }
    }

    // Параллельная загрузка
    final results = await Future.wait([
      riddleFuture(),
      wordFuture(),
      articleFuture(),
    ]);

    final riddle = results[0] as Riddle?;
    final word = results[1] as String?;
    final (titleArticle, article) = results[2] as (String?, WikiPage?);

    if (riddle != null && word != null) {
      if (article == null && titleArticle == null) {
        emit(DailyContentError('Ошибка при получении статьи.'));
        await Future.delayed(Duration(seconds: 5));
      }
      emit(
        DailyContentLoaded(
          riddle: riddle,
          word: word,
          article: article,
          titleArticle: titleArticle,
        ),
      );
    } else {
      emit(DailyContentError('Ошибка при получении контента.'));
    }
  }

  Future<void> _onCheckAndLoad(
    DailyContentCheckAndLoad event,
    Emitter<DailyContentState> emit,
  ) async {
    emit(DailyContentLoading());

    final currentDate = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = await _storageRepository.getCurrentDate();
    final isNewDay = savedDate != currentDate;

    if (isNewDay) {
      try {
        await _generateAndSaveContent(emit, reGenerate: true);
      } catch (e) {
        emit(DailyContentError('Ошибка: $e'));
      }
    } else {
      try {
        final riddle = await _storageRepository.loadRiddle();

        final word = await _storageRepository.loadWord();

        final titleArticle = await _storageRepository.loadTitleArticle();

        if (riddle != null && word != null && titleArticle != null) {
          final article = await _wikipediaRepository
              .getArticleFromTitle(title: titleArticle)
              .onError((e, ee) {
                return WikiPage();
              });
          emit(
            DailyContentLoaded(
              riddle: riddle,
              word: word,
              article: article,
              titleArticle: titleArticle,
            ),
          );
        } else {
          add(DailyContentRefresh());
        }
      } catch (e) {
        emit(DailyContentError('$e'));
      }
    }
  }

  Future<void> _onForceReset(
    DailyContentForceReset event,
    Emitter<DailyContentState> emit,
  ) async {
    // Сбрасываем все сохраненные данные
    _storageRepository.resetAll();

    // Загружаем новый контент
    add(DailyContentCheckAndLoad());
  }

  Future<void> _onRefresh(
    DailyContentRefresh event,
    Emitter<DailyContentState> emit,
  ) async {
    await _generateAndSaveContent(emit);
  }
}

sealed class DailyContentState {}

class DailyContentLoading extends DailyContentState {}

class DailyContentLoaded extends DailyContentState {
  final Riddle? riddle;
  final String? word;
  final WikiPage? article;
  final String? titleArticle;

  DailyContentLoaded({this.riddle, this.word, this.article, this.titleArticle});
}

class DailyContentError extends DailyContentState {
  final String message;

  DailyContentError(this.message);
}

sealed class DailyContentEvent {}

/// Проверка даты и загрузка данных при необходимости
class DailyContentCheckAndLoad extends DailyContentEvent {}

/// Принудительный сброс всех данных и загрузка нового
class DailyContentForceReset extends DailyContentEvent {}

/// Принудительное обновление данных
class DailyContentRefresh extends DailyContentEvent {}
