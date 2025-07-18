import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/data/api/api_client.dart';
import 'package:mind_stretch/data/repository/local/storage_repository_impl.dart';
import 'package:mind_stretch/data/repository/remote/deepseek_repository_impl.dart';
import 'package:mind_stretch/data/repository/remote/wikipedia_repository_impl.dart';
import 'package:mind_stretch/logic/cubit/word_cubit.dart';
import 'package:mind_stretch/logic/cubit/riddle_cubit.dart';
import 'package:mind_stretch/logic/cubit/article_bloc.dart';
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
      ],
      child: widget.child,
    );
  }
}
