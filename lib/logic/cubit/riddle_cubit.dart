import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';

class RiddleCubit extends Cubit<RiddleState> {
  final StorageRepository _storage;
  final DeepseekRepository _deepseek;

  RiddleCubit({
    required StorageRepository storage,
    required DeepseekRepository deepseek,
  }) : _storage = storage,
       _deepseek = deepseek,
       super(RiddleInitial()) {
    if (state is RiddleInitial) load();
  }

  Future<void> load({bool force = false}) async {
    emit(RiddleLoading());

    if (!force) {
      final riddle = await _storage.loadRiddle();
      if (riddle != null) {
        emit(RiddleLoaded(riddle: riddle));
        return;
      }
    }

    try {
      final riddle = await _deepseek.generate<Riddle>(
        type: GenerationType.riddle,
      );
      await _storage.saveRiddle(riddle: riddle.toString());
      emit(RiddleLoaded(riddle: riddle));
    } catch (e) {
      emit(RiddleError('Ошибка при генерации загадки: $e'));
    }
  }

  Future<void> refresh() async {
    final currentState = state is RiddleLoaded
        ? state as RiddleLoaded
        : RiddleLoaded();

    if (currentState.riddle == null) {
      emit(RiddleLoading());
      try {
        final riddle = await _deepseek.generate<Riddle>(
          type: GenerationType.riddle,
        );
        await _storage.saveRiddle(riddle: riddle.toString());
        emit(RiddleLoaded(riddle: riddle));
      } catch (e) {
        emit(RiddleError('Ошибка при обновлении загадки: $e'));
      }
    }
  }

  Future<void> resetAndLoad() async {
    await _storage.resetRiddle();
    await load(force: true);
  }
}

sealed class RiddleState {}

class RiddleInitial extends RiddleState {}

class RiddleLoading extends RiddleState {}

class RiddleLoaded extends RiddleState {
  final Riddle? riddle;
  RiddleLoaded({this.riddle});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RiddleLoaded && other.riddle == riddle);
  }

  @override
  int get hashCode => riddle.hashCode;
}

class RiddleError extends RiddleState {
  final String message;
  RiddleError(this.message);
}
