import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/cubit/article_cubit.dart';
import 'package:mind_stretch/logic/cubit/riddle_cubit.dart';
import 'package:mind_stretch/logic/cubit/settings_cubit.dart';
import 'package:mind_stretch/logic/cubit/word_cubit.dart';
import 'package:mind_stretch/logic/repository/local/storage_repository.dart';

class ControlContentScope extends StatelessWidget {
  final Widget child;

  const ControlContentScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (BuildContext context) => SettingsCubit(
        storage: context.read<StorageRepository>(),
        articleCubit: context.read<ArticleCubit>(),
        riddleCubit: context.read<RiddleCubit>(),
        wordCubit: context.read<WordCubit>(),
      ),
      child: child,
    );
  }
}
