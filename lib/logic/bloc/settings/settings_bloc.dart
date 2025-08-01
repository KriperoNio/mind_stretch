import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/core/storage/keys/settings_key.dart';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/data/models/storage/settings_model.dart';
import 'package:mind_stretch/logic/controllers/editable_fields_controller.dart';
import 'package:mind_stretch/logic/cubit/home/article_cubit.dart';
import 'package:mind_stretch/logic/cubit/home/riddle_cubit.dart';
import 'package:mind_stretch/logic/cubit/home/word_cubit.dart';
import 'package:mind_stretch/logic/error/effect_emitter.dart';
import 'package:mind_stretch/logic/error/effects/settings_effect.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState>
    with EffectEmitter<SettingsEffect> {
  final StorageRepository _storage;
  final ArticleCubit _articleCubit;
  final RiddleCubit _riddleCubit;
  final WordCubit _wordCubit;

  Map<SettingsKey, SettingsModel> _settingsMap = {};

  final EditableFieldsController fieldsController = EditableFieldsController();

  SettingsBloc({
    required StorageRepository storage,
    required ArticleCubit articleCubit,
    required RiddleCubit riddleCubit,
    required WordCubit wordCubit,
  }) : _storage = storage,
       _articleCubit = articleCubit,
       _riddleCubit = riddleCubit,
       _wordCubit = wordCubit,
       super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSpecificTopic>(_onUpdateSpecificTopic);
    on<ResetSpecificTopic>(_onResetSpecificTopic);
    on<RefreshContent>(_onRefreshContent);
    on<ResetContent>(_onResetContent);
    on<ResetSettings>(_onResetSettings);
    on<ClearSettings>(_onClearSettings);
  }

  Map<SettingsKey, SettingsModel> get settingsMap => _settingsMap;

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final result = <SettingsKey, SettingsModel>{};
      for (final key in SettingsKey.values) {
        final json = await _storage.getValue(
          key.section,
          StorageContentKey.settings,
        );
        result[key] = json != null
            ? SettingsModel.fromString(json)
            : SettingsModel();
      }

      AppLogger.debug('$result', name: 'SettingsBloc');
      _settingsMap = result;
      emit(SettingsInitial());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  void updateSpecificTextField(SettingsKey key, String newValue) {
    fieldsController.updateText(key, newValue);
  }

  Future<void> _onUpdateSpecificTopic(
    UpdateSpecificTopic event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final current = _settingsMap[event.key] ?? SettingsModel();
      final updated = current.copyWith(specificTopic: event.topic);
      await _storage.setValue(
        event.key.section,
        StorageContentKey.settings,
        updated.toString(),
      );
      _settingsMap[event.key] = updated;
      emit(SettingsSuccess());
    } catch (e) {
      emitEffect(ShowSnackbar(e.toString()));
    }
  }

  Future<void> _onResetSpecificTopic(
    ResetSpecificTopic event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await _storage.removeValue(event.key.section, StorageContentKey.settings);
      _settingsMap.remove(event.key);
      emit(SettingsSuccess());
    } catch (e) {
      emitEffect(ShowSnackbar(e.toString()));
    }
  }

  Future<void> _onRefreshContent(
    RefreshContent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await Future.wait([
        _articleCubit.refresh(),
        _riddleCubit.refresh(),
        _wordCubit.refresh(),
      ]);
      emit(SettingsSuccess());
    } catch (e) {
      emitEffect(ShowSnackbar(e.toString()));
    }
  }

  Future<void> _onResetContent(
    ResetContent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await Future.wait([
        _articleCubit.resetAndLoad(),
        _riddleCubit.resetAndLoad(),
        _wordCubit.resetAndLoad(),
      ]);
      emitEffect(PageBack());
      emit(SettingsSuccess());
    } catch (e) {
      emitEffect(ShowSnackbar(e.toString()));
    }
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await Future.wait([
        _storage.removeValue(
          SettingsKey.article.section,
          StorageContentKey.settings,
        ),
        _storage.removeValue(
          SettingsKey.riddle.section,
          StorageContentKey.settings,
        ),
        _storage.removeValue(
          SettingsKey.word.section,
          StorageContentKey.settings,
        ),
      ]);
      _settingsMap.clear();
      emit(SettingsSuccess());
    } catch (e) {
      emitEffect(ShowSnackbar(e.toString()));
    }
  }

  Future<void> _onClearSettings(
    ClearSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsInitial());
  }

  @override
  Future<void> close() {
    fieldsController.dispose();
    disposeEffects();
    return super.close();
  }
}

sealed class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdateSpecificTopic extends SettingsEvent {
  final SettingsKey key;
  final String topic;

  UpdateSpecificTopic({required this.key, required this.topic});
}

class ResetSpecificTopic extends SettingsEvent {
  final SettingsKey key;

  ResetSpecificTopic({required this.key});
}

class RefreshContent extends SettingsEvent {}

class ResetContent extends SettingsEvent {}

class ResetSettings extends SettingsEvent {}

class ClearSettings extends SettingsEvent {}

sealed class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsSuccess extends SettingsState {}

class SettingsError extends SettingsState {
  final Object error;
  SettingsError(this.error);
}
