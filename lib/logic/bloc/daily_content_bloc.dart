import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/data/models/wiki_page.dart';
import '../repository/local/storage_repository.dart';
import '../repository/remote/deepseek_repository.dart';
import '../repository/remote/wikipedia_repository.dart';

class DailyContentBloc extends Bloc<DailyContentEvent, DailyContentState> {
  final StorageRepository _storageRepository;
  final DeepseekRepository _deepseekRepository;
  final WikipediaRepository _wikipediaRepository;

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
        _storageRepository.resetAll();

        final riddle = await _deepseekRepository.generate<Riddle>(
          type: GenerationType.riddle,
        );

        final word = await _deepseekRepository.generate<String>(
          type: GenerationType.word,
        );

        final titleArticle = await _deepseekRepository.generate<String>(
          type: GenerationType.articleTitle,
        );

        final article = await _wikipediaRepository.getArticleFromTitle(
          title: titleArticle,
        );

        _storageRepository
          ..saveRiddle(riddle: riddle.toString())
          ..saveWord(word: word)
          ..saveTitleArticle(titleArticle: titleArticle)
          ..setCurrentDate(currentDate);

        emit(
          DailyContentLoaded(
            riddle: riddle,
            word: word,
            article: article,
            titleArticle: titleArticle,
          ),
        );
      } catch (e) {
        emit(DailyContentError('Ошибка: $e'));
      }
    } else {
      try {
        final riddle = await _storageRepository.loadRiddle();

        final word = await _storageRepository.loadWord();

        final title = await _storageRepository.loadTitleArticle();

        if (riddle != null && word != null && title != null) {
          final article = await _wikipediaRepository.getArticleFromTitle(
            title: title,
          );
          emit(
            DailyContentLoaded(
              riddle: riddle,
              word: word,
              article: article,
              titleArticle: title,
            ),
          );
        } else {
          add(DailyContentRefresh());
        }
      } catch (e) {
        emit(DailyContentError('Ошибка: $e'));
      }
    }
  }

  Future<void> _onForceReset(
    DailyContentForceReset event,
    Emitter<DailyContentState> emit,
  ) async {
    // Сбрасываем все сохраненные данные
    _storageRepository.resetAll();

    // Устанавливаем состояние загрузки
    emit(DailyContentLoading());

    // Загружаем новый контент
    add(DailyContentCheckAndLoad());
  }

  Future<void> _onRefresh(
    DailyContentRefresh event,
    Emitter<DailyContentState> emit,
  ) async {
    DailyContentLoaded current = state is DailyContentLoaded
        ? state as DailyContentLoaded
        : DailyContentLoaded();

    bool updated = false;

    Riddle? riddle = current.riddle;
    if (riddle == null) {
      riddle = await _deepseekRepository.generate<Riddle>(
        type: GenerationType.riddle,
      );
      _storageRepository.saveRiddle(riddle: riddle.toString());
      updated = true;
    }

    String? word = current.word;
    if (word == null) {
      word = await _deepseekRepository.generate<String>(
        type: GenerationType.word,
      );
      _storageRepository.saveWord(word: word);
      updated = true;
    }

    String? title = current.titleArticle;
    WikiPage? article = current.article;
    if (title == null || article == null) {
      title = await _deepseekRepository.generate<String>(
        type: GenerationType.articleTitle,
      );
      _storageRepository.saveTitleArticle(titleArticle: title);
      article =  await _wikipediaRepository.getArticleFromTitle(title: title);
      updated = true;
    }

    if (updated) {
      emit(
        DailyContentLoaded(
          riddle: riddle,
          word: word,
          titleArticle: title,
          article: article,
        ),
      );
    }
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
