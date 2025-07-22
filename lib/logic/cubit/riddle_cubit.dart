import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/core/storage/sections/storage_content_section.dart';
import 'package:mind_stretch/data/models/riddle.dart';
import 'package:mind_stretch/data/models/storage/content_with_settings_model.dart';
import 'package:mind_stretch/data/models/storage/settings_model.dart';
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
    load();
  }

  Future<void> load({bool force = false}) async {
    emit(RiddleLoading());

    ContentWithSettingsModel? model = await _storage.loadModel(
      StorageContentSection.riddle,
    );

    String? raw = force ? null : model?.content;

    if (raw == null) {
      try {
        final specificTopic = model?.settings.specificTopic;

        final riddle = await _deepseek.generate<Riddle>(
          type: GenerationType.riddle,
          specificTopic: specificTopic,
        );

        final updatedModel = ContentWithSettingsModel(
          content: riddle.toString(),
          settings: model?.settings ?? SettingsModel(),
        );

        await _storage.saveModel(StorageContentSection.riddle, updatedModel);
        model = updatedModel;
      } catch (e) {
        emit(RiddleError('Ошибка при генерации загадки: $e'));
        return;
      }
    }

    try {
      final parsed = Riddle.fromString(model!.content!);
      emit(RiddleLoaded(riddle: parsed, settings: model.settings));
    } catch (e) {
      emit(RiddleError('Ошибка при разборе загадки: $e'));
    }
  }

  Future<void> refresh() async {
    final current = state is RiddleLoaded ? state as RiddleLoaded : null;

    final model = await _storage.loadModel(StorageContentSection.riddle);

    final savedSettings = model?.settings;
    final savedRaw = model?.content;

    final currentSettings = current?.settings;
    final currentRaw = current?.riddle?.toString();

    final settingsChanged = savedSettings != currentSettings;
    final riddleChanged = savedRaw != currentRaw;
    final missingParsed = current?.riddle == null;

    AppLogger.debug(
      '>>> Refresh\n'
      '${'-' * 24}\n'
      '${savedSettings?.toJson()} | ${currentSettings?.toJson()}\n'
      '$settingsChanged\n'
      '${'-' * 24}\n'
      '$savedRaw | $currentRaw\n'
      '$riddleChanged\n'
      '${'-' * 24}\n'
      '$missingParsed\n',
      name: 'riddle_bloc\n',
    );

    if (settingsChanged) {
      try {
        final specificTopic = savedSettings?.specificTopic;

        final riddle = await _deepseek.generate<Riddle>(
          type: GenerationType.riddle,
          specificTopic: specificTopic,
        );

        final updatedModel = ContentWithSettingsModel(
          content: riddle.toString(),
          settings: savedSettings ?? SettingsModel(),
        );

        await _storage.saveModel(StorageContentSection.riddle, updatedModel);

        emit(RiddleLoaded(riddle: riddle, settings: updatedModel.settings));
      } catch (e) {
        emit(RiddleError('Ошибка при генерации загадки: $e'));
      }
    } else if (riddleChanged) {
      try {
        final parsed = Riddle.fromString(savedRaw!);
        emit(RiddleLoaded(riddle: parsed, settings: savedSettings));
      } catch (e) {
        emit(RiddleError('Ошибка при восстановлении загадки: $e'));
      }
    } else if (missingParsed && savedRaw != null) {
      try {
        final parsed = Riddle.fromString(savedRaw);
        emit(RiddleLoaded(riddle: parsed, settings: savedSettings));
      } catch (_) {
        try {
          final riddle = await _deepseek.generate<Riddle>(
            type: GenerationType.riddle,
            specificTopic: savedSettings?.specificTopic,
          );

          final updatedModel = ContentWithSettingsModel(
            content: riddle.toString(),
            settings: savedSettings ?? SettingsModel(),
          );

          await _storage.saveModel(StorageContentSection.riddle, updatedModel);

          emit(RiddleLoaded(riddle: riddle, settings: updatedModel.settings));
        } catch (e) {
          emit(RiddleError('Ошибка при повторной генерации загадки: $e'));
        }
      }
    }
  }

  Future<void> resetAndLoad() async {
    await _storage.removeValue(StorageContentSection.riddle, StorageContentKey.content);
    await load(force: true);
  }
}

sealed class RiddleState {}

class RiddleInitial extends RiddleState {}

class RiddleLoading extends RiddleState {}

class RiddleLoaded extends RiddleState {
  final Riddle? riddle;
  final SettingsModel? settings;

  RiddleLoaded({this.riddle, this.settings});

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
