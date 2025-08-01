import 'package:flutter/material.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/logic/error/effects/settings_effect.dart';

class SettingsEffectHandler {
  final BuildContext context;

  SettingsEffectHandler(this.context);

  void handle(SettingsEffect effect) {
    switch (effect) {
      case ShowSnackbar(:final message):
        AppLogger.warning('>>> $message');
        context.mounted
            ? ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)))
            : null;
        break;
      case PageBack(:final result):
        Navigator.pop(context, result);
        break;
    }
  }
}
