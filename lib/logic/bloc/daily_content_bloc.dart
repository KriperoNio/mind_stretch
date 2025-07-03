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
      _storageRepository.resetAll();

      final riddle = await _deepseekRepository.generate<Riddle>(
        type: GenerationType.riddle,
      );
      _storageRepository.saveRiddle(riddle: riddle.toString());
      emit(DailyContentLoaded().copyWith(riddle: riddle));

      final word = await _deepseekRepository.generate<String>(
        type: GenerationType.word,
      );
      _storageRepository.saveWord(word: word);
      emit(DailyContentLoaded().copyWith(word: word));

      final titleArticle = await _deepseekRepository.generate<String>(
        type: GenerationType.articleTitle,
      );
      _storageRepository.saveTitleArticle(titleArticle: titleArticle);
      final article = await _wikipediaRepository.getArticleFromTitle(
        title: titleArticle,
      );
      emit(
        DailyContentLoaded().copyWith(
          article: article,
          titleArticle: titleArticle,
        ),
      );

      _storageRepository.setCurrentDate(currentDate);
    } else {
      final riddle = await _storageRepository.loadRiddle();
      emit(DailyContentLoaded().copyWith(riddle: riddle));

      final word = await _storageRepository.loadWord();
      emit(DailyContentLoaded().copyWith(word: word));

      final title = await _storageRepository.loadTitleArticle();
      emit(DailyContentLoaded().copyWith(titleArticle: title));

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
    }
  }

  Future<void> _onRefresh(
    DailyContentRefresh event,
    Emitter<DailyContentState> emit,
  ) async {
    // Если не DailyContentLoaded — сбрасываем всё и загружаем заново
    if (state is! DailyContentLoaded) {
      await _storageRepository.resetAll();
      emit(DailyContentLoading());
    }

    DailyContentLoaded current = state is DailyContentLoaded
        ? state as DailyContentLoaded
        : DailyContentLoaded();

    bool updated = false;

    if (current.riddle == null) {
      final riddle = await _deepseekRepository.generate<Riddle>(
        type: GenerationType.riddle,
      );
      await _storageRepository.saveRiddle(riddle: riddle.toString());
      emit(current.copyWith(riddle: riddle));
      updated = true;
    }

    if (current.word == null) {
      final word = await _deepseekRepository.generate<String>(
        type: GenerationType.word,
      );
      await _storageRepository.saveWord(word: word);
      emit(current.copyWith(word: word));
      updated = true;
    }

    if (current.article == null || current.titleArticle == null) {
      final titleArticle = await _deepseekRepository.generate<String>(
        type: GenerationType.articleTitle,
      );
      await _storageRepository.saveTitleArticle(titleArticle: titleArticle);

      final article = await _wikipediaRepository.getArticleFromTitle(
        title: titleArticle,
      );

      emit(current.copyWith(titleArticle: titleArticle, article: article));
      updated = true;
    }

    if (updated) emit(current);
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

  DailyContentLoaded copyWith({
    Riddle? riddle,
    String? word,
    WikiPage? article,
    String? titleArticle,
  }) {
    return DailyContentLoaded(
      riddle: riddle ?? this.riddle,
      word: word ?? this.word,
      article: article ?? this.article,
      titleArticle: titleArticle ?? this.titleArticle,
    );
  }
}

class DailyContentError extends DailyContentState {
  final String message;

  DailyContentError(this.message);
}

sealed class DailyContentEvent {}

/// Проверка даты и загрузка данных при необходимости
class DailyContentCheckAndLoad extends DailyContentEvent {}

/// Принудительное обновление данных
class DailyContentRefresh extends DailyContentEvent {
  final DailyContentLoaded? dailyContentState;

  DailyContentRefresh({this.dailyContentState});
}
