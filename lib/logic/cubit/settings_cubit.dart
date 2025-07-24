import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/storage/keys/settings_key.dart';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/logic/cubit/article_cubit.dart';
import 'package:mind_stretch/logic/cubit/riddle_cubit.dart';
import 'package:mind_stretch/logic/cubit/word_cubit.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageRepository _storage;
  final ArticleCubit _articleCubit;
  final RiddleCubit _riddleCubit;
  final WordCubit _wordCubit;

  SettingsCubit({
    required StorageRepository storage,
    required ArticleCubit articleCubit,
    required RiddleCubit riddleCubit,
    required WordCubit wordCubit,
  }) : _articleCubit = articleCubit,
       _riddleCubit = riddleCubit,
       _wordCubit = wordCubit,
       _storage = storage,
       super(SettingsInitial());

  Future<void> loadCurrentSettings({required SettingsKey key}) async {
    emit(SettingsLoading());
    try {
      await Future.wait([
        _articleCubit.refresh(),
        _riddleCubit.refresh(),
        _wordCubit.refresh(),
      ]);
      if (!isClosed) emit(SettingsSuccess());
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> refreshContent() async {
    emit(SettingsLoading());
    try {
      await Future.wait([
        _articleCubit.refresh(),
        _riddleCubit.refresh(),
        _wordCubit.refresh(),
      ]);
      if (!isClosed) emit(SettingsSuccess());
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> resetContent() async {
    emit(SettingsLoading());
    try {
      await Future.wait([
        _articleCubit.resetAndLoad(),
        _riddleCubit.resetAndLoad(),
        _wordCubit.resetAndLoad(),
      ]);
      if (!isClosed) emit(SettingsSuccess());
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> resetSettings() async {
    emit(SettingsLoading());
    try {
      await Future.wait([
        _storage.removeValue(
          SettingsKey.article.section,
          StorageContentKey.settings,
        ),

        _storage.removeValue(
          SettingsKey.article.section,
          StorageContentKey.settings,
        ),

        _storage.removeValue(
          SettingsKey.article.section,
          StorageContentKey.settings,
        ),
      ]);
      if (!isClosed) emit(SettingsSuccess());
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  void clear() {
    emit(SettingsInitial());
  }
}

sealed class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsSuccess extends SettingsState {}

class SettingsFailure extends SettingsState {
  final String error;
  SettingsFailure(this.error);
}
