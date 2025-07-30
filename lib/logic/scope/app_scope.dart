import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/repository/local/storage_repository_impl.dart';
import 'package:mind_stretch/data/repository/remote/deepseek_repository_impl.dart';
import 'package:mind_stretch/data/repository/remote/wikipedia_repository_impl.dart';
import 'package:mind_stretch/logic/bloc/settings/settings_bloc.dart';
import 'package:mind_stretch/logic/cubit/home/article_cubit.dart';
import 'package:mind_stretch/logic/cubit/home/riddle_cubit.dart';
import 'package:mind_stretch/logic/cubit/home/word_cubit.dart';
import 'package:mind_stretch/logic/cubit/settings/topic_chips_cubit.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';
import 'package:mind_stretch/logic/repository/remote/deepseek_repository.dart';
import 'package:mind_stretch/logic/repository/remote/wikipedia_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScope extends StatefulWidget {
  final Widget child;

  const AppScope({required this.child, super.key});

  @override
  State<AppScope> createState() => _AppScropeState();
}

class _AppScropeState extends State<AppScope> {
  late final Future<SharedPreferences> prefs;
  late final ApiClient apiClient;

  late final WikipediaRepository wikipediaRepository;
  late final DeepseekRepository deepseekRepository;
  late final StorageRepository storageRepository;

  late final ArticleCubit articleCubit;
  late final RiddleCubit riddleCubit;
  late final WordCubit wordCubit;

  late final TopicChipsCubit topicChipsCubit;

  late final SettingsBloc settingsBloc;

  @override
  void initState() {
    super.initState();
    prefs = SharedPreferences.getInstance();
    apiClient = ApiClient();

    wikipediaRepository = WikipediaRepositoryImpl(apiClient: apiClient);
    deepseekRepository = DeepseekRepositoryImpl(apiClient: apiClient);
    storageRepository = StorageRepositoryImpl(prefs: prefs);

    articleCubit = ArticleCubit(
      storage: storageRepository,
      deepseek: deepseekRepository,
      wikipedia: wikipediaRepository,
    );
    riddleCubit = RiddleCubit(
      storage: storageRepository,
      deepseek: deepseekRepository,
    );
    wordCubit = WordCubit(
      storage: storageRepository,
      deepseek: deepseekRepository,
    );

    topicChipsCubit = TopicChipsCubit(
      storage: storageRepository,
      deepseek: deepseekRepository,
    );

    settingsBloc = SettingsBloc(
      storage: storageRepository,
      articleCubit: articleCubit,
      riddleCubit: riddleCubit,
      wordCubit: wordCubit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RiddleCubit>(
          create: (BuildContext context) => riddleCubit,
        ),
        BlocProvider<WordCubit>(create: (BuildContext context) => wordCubit),
        BlocProvider<ArticleCubit>(
          create: (BuildContext context) => articleCubit,
        ),
        BlocProvider<TopicChipsCubit>(
          create: (BuildContext context) => topicChipsCubit,
        ),
        RepositoryProvider<StorageRepository>(
          create: (context) => storageRepository,
        ),
        BlocProvider<SettingsBloc>(
          create: (BuildContext context) => settingsBloc..add(LoadSettings()),
        ),
      ],
      child: widget.child,
    );
  }
}
