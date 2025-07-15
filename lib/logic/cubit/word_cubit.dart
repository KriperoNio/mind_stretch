import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/data/repository/local/storage_repository_impl.dart';
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
    if (state is WordInitial) load();
  }

  Future<void> load({bool force = false}) async {
    emit(WordLoading());

    if (!force) {
      final word = await _storage.load(StorageContentKey.word.key);
      if (word != null) {
        emit(WordLoaded(word: word));
        return;
      }
    }

    try {
      final word = await _deepseek.generate<String>(type: GenerationType.word);
      await _storage.save(StorageContentKey.word.key, word);
      emit(WordLoaded(word: word));
    } catch (e) {
      emit(WordError('Ошибка при генерации слова: $e'));
    }
  }

  Future<void> refresh() async {
    final currentState = state is WordLoaded
        ? state as WordLoaded
        : WordLoaded();

    if (currentState.word == null) {
      emit(WordLoading());
      try {
        final word = await _deepseek.generate<String>(
          type: GenerationType.word,
        );
        await _storage.save(StorageContentKey.word.key, word);
        emit(WordLoaded(word: word));
      } catch (e) {
        emit(WordError('Ошибка при обновлении слова: $e'));
      }
    }
  }

  Future<void> resetAndLoad() async {
    await _storage.reset(StorageContentKey.word.key);
    await load(force: true);
  }
}

sealed class WordState {}

class WordInitial extends WordState {}

class WordLoading extends WordState {}

class WordLoaded extends WordState {
  final String? word;
  WordLoaded({this.word});
}

class WordError extends WordState {
  final String message;
  WordError(this.message);
}
