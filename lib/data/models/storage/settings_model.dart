import 'dart:convert';

class SettingsModel {
  final int? maxTokens;
  final String? specificTopic;

  SettingsModel({this.maxTokens, this.specificTopic});

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      maxTokens: json['maxTokens'] as int?,
      specificTopic: json['specificTopic'] as String?,
    );
  }

  factory SettingsModel.fromString(String source) {
    try {
      final Map<String, dynamic> json = jsonDecode(source);
      return SettingsModel.fromJson(json);
    } catch (e) {
      return SettingsModel();
    }
  }

  Map<String, dynamic> toJson() {
    return {'maxTokens': maxTokens, 'specificTopic': specificTopic};
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  SettingsModel copyWith({int? maxTokens, String? specificTopic}) {
    return SettingsModel(
      maxTokens: maxTokens ?? this.maxTokens,
      specificTopic: specificTopic ?? this.specificTopic,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel &&
        other.maxTokens == maxTokens &&
        other.specificTopic == specificTopic;
  }

  @override
  int get hashCode => Object.hash(maxTokens, specificTopic);
}
