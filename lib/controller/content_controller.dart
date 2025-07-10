import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/cubit/article_bloc.dart';
import 'package:mind_stretch/logic/cubit/riddle_cubit.dart';
import 'package:mind_stretch/logic/cubit/word_cubit.dart';

class ContentController extends Cubit<void> {
  final ArticleCubit _articleCubit;
  final RiddleCubit _riddleCubit;
  final WordCubit _wordCubit;

  ContentController({
    required ArticleCubit articleCubit,
    required RiddleCubit riddleCubit,
    required WordCubit wordCubit,
  }) : _articleCubit = articleCubit,
       _riddleCubit = riddleCubit,
       _wordCubit = wordCubit,
       super(null);

  Future<void> refreshContent({
    VoidCallback? onComplete,
    Function(Object)? onError,
  }) async {
    try {
      await Future.wait([
        _articleCubit.refresh(),
        _riddleCubit.refresh(),
        _wordCubit.refresh(),
      ]);
      onComplete?.call();
    } catch (e) {
      onError?.call(e);
    }
  }

  Future<void> resetContent({
    VoidCallback? onComplete,
    Function(Object)? onError,
  }) async {
    try {
      await Future.wait([
        _articleCubit.resetAndLoad(),
        _riddleCubit.resetAndLoad(),
        _wordCubit.resetAndLoad(),
      ]);
      onComplete?.call();
    } catch (e) {
      onError?.call(e);
    }
  }
}
