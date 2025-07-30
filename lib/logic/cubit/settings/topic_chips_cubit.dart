import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/core/storage/sections/storage_content_section.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';

class TopicChipsCubit extends Cubit<TopicChipsState> { // mixin EffectEmitter<> 
  final StorageRepository _storage;
  final DeepseekRepository _deepseek;

  List<String> _allchips = [];
  Map<String, String> _generatedMapTopics = {};

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
          generatedChips.toString(),
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

  Stream<String?> generateSpecificTopics({
    required String specificTopic,
    required List<String> forA,
  }) async* {
    final mapTopics = await _deepseek.generate<Map<String, String>?>(
      type: GenerationType.specificTopics,
    );
    if (mapTopics == null) {
      _generatedMapTopics = mapTopics!;
      for (var key in forA) {
        yield _generatedMapTopics[key];
      }
    } else {
      emit(
        TopicChipsError('Ошибка при генерации запросов специальных тем: $e', e),
      );
    }
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
