import 'package:flutter/material.dart';

class AppTheme {
  final Brightness? brightness;

  AppTheme(this.brightness);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Color(0xFFFCE5B9),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFFCE5B9),
        brightness: Brightness.light,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(0xFFFCE5B9),

      textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 16)),

      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFFCE5B9),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
      ),

      chipTheme: ChipThemeData(backgroundColor: Color(0xFFFCF2E5)),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size.fromHeight(60),
          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          iconSize: 32,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(iconSize: 32),
      ),
    );
  }
}
