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

  Map<String, dynamic> toJson() {
    return {'maxTokens': maxTokens, 'specificTopic': specificTopic};
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
