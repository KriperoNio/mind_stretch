import 'package:mind_stretch/data/models/storage/settings_model.dart';

class GenerationModel {
  final String? specificTopic;
  final List<String>? forA;
  final double? temperature;
  final int? maxTokens;

  const GenerationModel({
    this.specificTopic,
    this.forA,
    this.temperature,
    this.maxTokens,
  });

  /// Создание из настроек
  factory GenerationModel.fromSettings(SettingsModel? settings) {
    return GenerationModel(
      specificTopic: settings?.specificTopic,
      maxTokens: settings?.maxTokens,
    );
  }

  /// Преобразование в удобную форму для `generate<T>()`
  Map<String, dynamic> toArguments() {
    return {
      'specificTopic': specificTopic,
      'forA': forA,
      'temperature': temperature,
      'maxTokens': maxTokens,
    };
  }

  @override
  String toString() {
    return 'GenerationModel(specificTopic: $specificTopic, forA: $forA, '
        'temperature: $temperature, maxTokens: $maxTokens)';
  }
}
