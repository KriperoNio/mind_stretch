import 'package:flutter/widgets.dart';
import 'package:mind_stretch/core/storage/keys/settings_key.dart';

class EditableFieldsController {
  final Map<SettingsKey, TextEditingController> _controllers = {};
  final Map<SettingsKey, ValueNotifier<bool>> _editableMap = {};

  TextEditingController controllerFor(SettingsKey key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
  }

  void updateText(SettingsKey key, String value) {
    if (_controllers.containsKey(key)) {
      _controllers[key]!.text = value;
    }
  }

  ValueNotifier<bool> editableNotifierFor(SettingsKey key) {
    return _editableMap.putIfAbsent(key, () => ValueNotifier(false));
  }

  bool isEditable(SettingsKey key) => _editableMap[key]?.value ?? false;

  void setEditable(SettingsKey key, bool value) {
    _editableMap[key]?.value = value;
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final value in _editableMap.values) {
      value.dispose();
    }
    _controllers.clear();
    _editableMap.clear();
  }
}
