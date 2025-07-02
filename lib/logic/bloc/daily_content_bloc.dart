import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/data/models/riddle.dart';
import '../repository/local/storage_repository.dart';
import '../repository/remote/deepseek_repository.dart';
import '../repository/remote/wikipedia_repository.dart';
import 'daily_content_event.dart';
import 'daily_content_state.dart';

class DailyContentBloc extends Bloc<DailyContentEvent, DailyContentState> {
  final StorageRepository storageRepository;
  final DeepseekRepository deepseekRepository;
  final WikipediaRepository wikipediaRepository;

  DailyContentBloc({
    required this.storageRepository,
    required this.deepseekRepository,
    required this.wikipediaRepository,
  }) : super(DailyContentLoading()) {
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
    final savedDate = storageRepository.currentDate;

    final isNewDay = savedDate != currentDate;

    if (isNewDay) {
      // Генерация новых данных
      final riddle = await deepseekRepository.generate<Riddle>(
        type: GenerationType.riddle,
      );
      final word = await deepseekRepository.generate<String>(
        type: GenerationType.word,
      );
      final titleArticle = await deepseekRepository.generate<String>(
        type: GenerationType.articleTitle,
      );
      final article = await wikipediaRepository.getArticleFromTitle(
        title: titleArticle,
      );
      
      storageRepository.saveRiddle(riddle: riddle.toString());
      storageRepository.saveWord(word: word);
      storageRepository.saveTitleArticle(titleArticle: titleArticle);
      storageRepository.currentDate = currentDate; // сохраняем новую дату

      emit(DailyContentLoaded(riddle: riddle, word: word, article: article));
    } else {
      final riddle = storageRepository.loadRiddle();
      final word = storageRepository.loadWord();
      final title = storageRepository.loadTitleArticle();

      if (riddle != null && word != null && title != null) {
        final article = await wikipediaRepository.getArticleFromTitle(
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

    final riddle = await deepseekRepository.generate<Riddle>(
      type: GenerationType.riddle,
    );
    final word = await deepseekRepository.generate<String>(
      type: GenerationType.word,
    );
    final titleArticle = await deepseekRepository.generate<String>(
      type: GenerationType.articleTitle,
    );
    final article = await wikipediaRepository.getArticleFromTitle(
      title: titleArticle,
    );

    storageRepository.saveRiddle(riddle: riddle.toString());
    storageRepository.saveWord(word: word);
    storageRepository.saveTitleArticle(titleArticle: titleArticle);

    emit(DailyContentLoaded(riddle: riddle, word: word, article: article));
  }
}
