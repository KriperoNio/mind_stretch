import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_stretch/logic/scopes/app_scope.dart';
import 'package:mind_stretch/ui/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Инициализация Flutter

  // Инициализация окружения и зависимостей
  await dotenv.load(fileName: ".env"); // Загрузка API ключей из .env

  runApp(AppScope(child: MindStretch()));
}

class MindStretch extends StatelessWidget {
  const MindStretch({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
      child: MaterialApp(
        title: 'Mind Stretch',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: HomePage(),
      ),
    );
  }
}
