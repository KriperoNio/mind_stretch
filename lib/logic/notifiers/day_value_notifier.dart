import 'dart:async';

import 'package:flutter/foundation.dart';

class DayValueNotifier extends ValueNotifier<DateTime> {
  DayValueNotifier() : super(DateTime.now()) {
    _initTimer();
  }

  void _initTimer() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.day != value.day || 
          now.month != value.month || 
          now.year != value.year) {
        value = now; // Автоматически уведомит слушателей
      }
    });
  }

  String get todayKey => '${value.year}-${value.month}-${value.day}';
}