import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/repository/local/storage_repository_impl.dart';
import 'package:mind_stretch/data/repository/remote/deepseek_repository_impl.dart';
import 'package:mind_stretch/data/repository/remote/wikipedia_repository_impl.dart';
import 'package:mind_stretch/logic/bloc/daily_content_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Инициализация Flutter

  // Инициализация окружения и зависимостей
  await dotenv.load(fileName: ".env"); // Загрузка API ключей из .env
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final ApiClient apiClient = ApiClient();

  runApp(MindStretch(prefs: prefs, apiClient: apiClient));
}

class MindStretch extends StatelessWidget {
  final Future<SharedPreferences> prefs;
  final ApiClient apiClient;
  const MindStretch({super.key, required this.prefs, required this.apiClient});

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
            storageRepository: StorageRepositoryImpl(prefs: prefs),
            deepseekRepository: DeepseekRepositoryImpl(apiClient: apiClient),
            wikipediaRepository: WikipediaRepositoryImpl(apiClient: apiClient),
          )..add(DailyContentCheckAndLoad()),
          child: BlocBuilder<DailyContentBloc, DailyContentState>(
            builder: (context, state) {
              if (state is DailyContentLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DailyContentLoaded) {
                return Scaffold(
                  appBar: AppBar(),
                  body: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Загадка: ${state.riddle.riddle}'),
                          Text('Слово дня: ${state.word}'),
                          Text('Статья: ${state.article.title}'),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(state.article.extract!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Text('Ошибка загрузки');
              }
            },
          ),
        ),
      ),
    );
  }
}
