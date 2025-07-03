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
  }) : _deepseekRepository = deepseekRepository,
       _storageRepository = storageRepository,
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

    final currentDate = DateTime.now().toIso8601String().substring(
      0,
      10,
    ); // YYYY-MM-DD
    final savedDate = await _storageRepository.getCurrentDate();

    final isNewDay = savedDate != currentDate;

    if (isNewDay) {
      // Генерация новых данных
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

      _storageRepository.saveRiddle(riddle: riddle.toString());
      _storageRepository.saveWord(word: word);
      _storageRepository.saveTitleArticle(titleArticle: titleArticle);
      _storageRepository.setCurrentDate(currentDate); // сохраняем новую дату

      emit(DailyContentLoaded(riddle: riddle, word: word, article: article));
    } else {
      final riddle = await _storageRepository.loadRiddle();
      final word = await _storageRepository.loadWord();
      final title = await _storageRepository.loadTitleArticle();

      if (riddle != null && word != null && title != null) {
        final article = await _wikipediaRepository.getArticleFromTitle(
          title: title,
        );
        emit(DailyContentLoaded(riddle: riddle, word: word, article: article));
      } else {
        add(
          DailyContentRefresh(), // если что-то не найдено - принудительно обновляем
        );
      }
    }
  }

  Future<void> _onRefresh(
    DailyContentRefresh event,
    Emitter<DailyContentState> emit,
  ) async {
    emit(DailyContentLoading());

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

    _storageRepository.saveRiddle(riddle: riddle.toString());
    _storageRepository.saveWord(word: word);
    _storageRepository.saveTitleArticle(titleArticle: titleArticle);

    emit(DailyContentLoaded(riddle: riddle, word: word, article: article));
  }
}

sealed class DailyContentState {}

class DailyContentLoading extends DailyContentState {}

class DailyContentLoaded extends DailyContentState {
  final Riddle riddle;
  final String word;
  final WikiPage article;

  DailyContentLoaded({
    required this.riddle,
    required this.word,
    required this.article,
  });
}

class DailyContentError extends DailyContentState {
  final String message;

  DailyContentError(this.message);
}

sealed class DailyContentEvent {}

/// Проверка даты и загрузка данных при необходимости
class DailyContentCheckAndLoad extends DailyContentEvent {}

/// Принудительное обновление данных
class DailyContentRefresh extends DailyContentEvent {}
