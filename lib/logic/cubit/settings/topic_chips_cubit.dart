import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/core/storage/sections/storage_content_section.dart';
import 'package:mind_stretch/data/models/generation_model.dart';
import 'package:mind_stretch/logic/error/effect_emitter.dart';
import 'package:mind_stretch/logic/error/effects/settings_effect.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';

class TopicChipsCubit extends Cubit<TopicChipsState>
    with EffectEmitter<SettingsEffect> {
  // mixin EffectEmitter<>
  final StorageRepository _storage;
  final DeepseekRepository _deepseek;

  List<String> _allchips = [];

  TopicChipsCubit({
    required StorageRepository storage,
    required DeepseekRepository deepseek,
  }) : _storage = storage,
       _deepseek = deepseek,
       super(TopicChipsInitial()) {
    load();
  }

  List<String> get chips =>
      (_allchips.toList()..shuffle(Random())).take(8).toList();

  Future<void> load({bool force = false}) async {
    emit(TopicChipsGeneration());

    String? stringList = force
        ? null
        : await _storage.getValue(
            StorageContentSection.topicChips,
            StorageContentKey.content,
          );

    if (stringList == null) {
      try {
        final List<String> generatedChips = await _deepseek
            .generate<List<String>>(type: GenerationType.topicChips);

        await _storage.setValue(
          StorageContentSection.topicChips,
          StorageContentKey.content,
          jsonEncode(generatedChips),
        );
        _allchips = generatedChips;
        emit(TopicChipsGenerated(chips: chips));
      } catch (e) {
        emit(TopicChipsError('Ошибка при генерации предлагаемых тем: $e', e));
        return;
      }
    } else {
      try {
        AppLogger.info('>>> $stringList', name: 'TopicChipsCubit');
        final decoded = jsonDecode(stringList) as List<dynamic>;
        _allchips = decoded.cast<String>();
        emit(TopicChipsGenerated(chips: chips));
      } catch (e) {
        emit(TopicChipsError('Ошибка при отображении предлагаемых тем: $e', e));
        return;
      }
    }
  }

  Future<void> resetAndLoad() async {
    await _storage.removeValue(
      StorageContentSection.topicChips,
      StorageContentKey.content,
    );
    await load(force: true);
  }

  Future<Map<String, String>?> generateSpecificTopicsPrompts({
    required String specificTopic,
    required List<String> forA,
  }) async {
    if (forA.isEmpty) {
      emitEffect(ShowSnackbar('Ошибка при генерации тем: пустой результат'));
      return null;
    }
    try {
      final mapTopicPromts = await _deepseek.generate<Map<String, String>?>(
        type: GenerationType.specificTopicPromts,
        generationModel: GenerationModel(
          specificTopic: specificTopic,
          forA: forA,
        ),
      );

      if (mapTopicPromts == null) {
        emitEffect(ShowSnackbar('Ошибка при генерации тем: пустой результат'));
        return null;
      }

      return mapTopicPromts;
    } catch (e) {
      emitEffect(
        ShowSnackbar('Ошибка при генерации запросов специальных тем: $e'),
      );
      return null;
    }
  }

  @override
  Future<void> close() {
    disposeEffects();
    return super.close();
  }
}

sealed class TopicChipsState {}

class TopicChipsInitial extends TopicChipsState {}

class TopicChipsGeneration extends TopicChipsState {}

class TopicChipsGenerated extends TopicChipsState {
  List<String> chips;

  TopicChipsGenerated({required this.chips});
}

class TopicChipsError extends TopicChipsState {
  final String message;
  final Object? error;
  TopicChipsError(this.message, [this.error]);
}
