import 'package:flutter/material.dart';

class AppTheme {
  final Brightness? brightness;

  AppTheme(this.brightness);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.lime.shade100,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lime.shade100,
        brightness: Brightness.light,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.lime.shade100,
      textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 16)),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.lime.shade100,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.blueGrey.shade800,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey.shade800,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.blueGrey.shade800,
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 16),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blueGrey.shade800,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
