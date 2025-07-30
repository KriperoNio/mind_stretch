import 'package:mind_stretch/core/storage/keys/storage_content_key.dart';
import 'package:mind_stretch/core/storage/section_provider.dart';
import 'package:mind_stretch/data/models/storage/content_with_settings_model.dart';

abstract class StorageRepository {
  Future<String?> getValue(SectionProvider section, StorageContentKey key);
  Future<void> setValue(
    SectionProvider section,
    StorageContentKey key,
    String value,
  );
  Future<void> removeValue(SectionProvider section, StorageContentKey key);
  Future<void> resetSection(SectionProvider section);
  Future<ContentWithSettingsModel?> loadModel(SectionProvider section);
  Future<void> saveModel(
    SectionProvider section,
    ContentWithSettingsModel model,
  );
}
