import 'package:mind_stretch/data/models/storage/settings_model.dart';

class ContentWithSettingsModel {
  final String? content;
  final SettingsModel settings;

  ContentWithSettingsModel({
    required this.content,
    required this.settings,
  });

  factory ContentWithSettingsModel.fromJson(Map<String, dynamic> json) {
    return ContentWithSettingsModel(
      content: json['content'] as String?,
      settings: SettingsModel.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'settings': settings.toJson(),
    };
  }
}
