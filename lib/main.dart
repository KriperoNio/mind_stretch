import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/repository/local/storage_repository_impl.dart';
import 'package:mind_stretch/data/repository/remote/deepseek_repository_impl.dart';
import 'package:mind_stretch/data/repository/remote/wikipedia_repository_impl.dart';
import 'package:mind_stretch/logic/bloc/daily_content_bloc.dart';
import 'package:mind_stretch/logic/notifiers/day_value_notifier.dart';
import 'package:mind_stretch/ui/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Инициализация Flutter

  // Инициализация окружения и зависимостей
  await dotenv.load(fileName: ".env"); // Загрузка API ключей из .env
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final ApiClient apiClient = ApiClient();
  // Нотифаер для отслеживания в запущеном состоянии изменения дня
  final dayNotifier = DayValueNotifier();

  runApp(
    MindStretch(prefs: prefs, apiClient: apiClient, dayNotifier: dayNotifier),
  );
}

class MindStretch extends StatelessWidget {
  final Future<SharedPreferences> prefs;
  final DayValueNotifier dayNotifier;
  final ApiClient apiClient;
  
  const MindStretch({
    super.key,
    required this.prefs,
    required this.apiClient,
    required this.dayNotifier,
  });

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
        home: BlocProvider(
          create: (_) => DailyContentBloc(
            dayNotifier: dayNotifier,
            storageRepository: StorageRepositoryImpl(prefs: prefs),
            deepseekRepository: DeepseekRepositoryImpl(apiClient: apiClient),
            wikipediaRepository: WikipediaRepositoryImpl(apiClient: apiClient),
          )..add(DailyContentCheckAndLoad()),
          child: HomePage(),
        ),
      ),
    );
  }
}
