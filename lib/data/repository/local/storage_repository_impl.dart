import 'dart:convert';
import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/core/storage/section_provider.dart';
import 'package:mind_stretch/data/models/storage/content_with_settings_model.dart';
import 'package:mind_stretch/data/models/storage/settings_model.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepositoryImpl implements StorageRepository {
  final Future<SharedPreferences> _prefs;

  const StorageRepositoryImpl({required Future<SharedPreferences> prefs})
    : _prefs = prefs;

  @override
  Future<String?> getValue(
    SectionProvider section,
    StorageContentKey key,
  ) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(section.storageKey);
    if (jsonString == null) return null;

    final data = json.decode(jsonString) as Map<String, dynamic>;

    if (key == StorageContentKey.settings) {
      // Возвращаем все настройки в виде json строки
      // В дальнейшем можно сделать расширенный ключ
      final settings = data['settings'];
      if (settings == null) return null;
      final settingsModel = SettingsModel.fromJson(settings);
      return json.encode(settingsModel.toJson());
    }

    return data[key.key] as String?;
  }

  @override
  Future<void> setValue(
    SectionProvider section,
    StorageContentKey key,
    String value,
  ) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(section.storageKey);
    final Map<String, dynamic> data = jsonString != null
        ? json.decode(jsonString)
        : {};

    if (key == StorageContentKey.settings) {
      // value должен быть валидным JSON-строкой
      try {
        final Map<String, dynamic> settingsMap = json.decode(value);
        final settingsModel = SettingsModel.fromJson(settingsMap);
        data['settings'] = settingsModel.toJson();
      } catch (e) {
        // Бросаем ошибку, чтобы разработчик знал о неправильном формате
        throw FormatException('Invalid JSON string for settings: $e');
      }
    } else {
      data[key.key] = value;
    }

    await prefs.setString(section.storageKey, json.encode(data));
  }

  @override
  Future<void> removeValue(
    SectionProvider section,
    StorageContentKey key,
  ) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(section.storageKey);
    if (jsonString == null) return;

    final Map<String, dynamic> data = json.decode(jsonString);

    if (key == StorageContentKey.settings) {
      data.remove('settings');
    } else {
      data.remove(key.key);
    }

    if (data.isEmpty) {
      await prefs.remove(section.storageKey);
    } else {
      await prefs.setString(section.storageKey, json.encode(data));
    }
  }

  @override
  Future<void> resetSection(SectionProvider section) async {
    final prefs = await _prefs;
    await prefs.remove(section.storageKey);
  }

  @override
  Future<ContentWithSettingsModel?> loadModel(SectionProvider section) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(section.storageKey);
    if (jsonString == null) return null;

    final Map<String, dynamic> data = json.decode(jsonString);
    return ContentWithSettingsModel.fromJson(data);
  }

  @override
  Future<void> saveModel(
    SectionProvider section,
    ContentWithSettingsModel model,
  ) async {
    final prefs = await _prefs;
    await prefs.setString(section.storageKey, json.encode(model.toJson()));
  }
}
