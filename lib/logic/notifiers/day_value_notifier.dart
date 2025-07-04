import 'dart:async';

import 'package:flutter/material.dart';

// Решил не придумыват велосипед через Stream 
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
        value = now; // Уведомит слушателей
      }
    });
  }
}