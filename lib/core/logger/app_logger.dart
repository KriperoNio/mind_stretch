import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  final int level;
  const LogLevel(this.level);
}

class AppLogger {
  static bool _enabled = kDebugMode;

  static void enable() => _enabled = true;
  static void disable() => _enabled = false;

  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String name = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;

    dev.log(
      message,
      name: name,
      level: level.level,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, {String name = 'App'}) =>
      log(message, level: LogLevel.debug, name: name);

  static void info(String message, {String name = 'App'}) =>
      log(message, level: LogLevel.info, name: name);

  static void warning(String message, {String name = 'App'}) =>
      log(message, level: LogLevel.warning, name: name);

  static void error(
    String message, {
    String name = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    message,
    level: LogLevel.error,
    name: name,
    error: error,
    stackTrace: stackTrace,
  );
}
