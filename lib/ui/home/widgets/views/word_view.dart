import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/cubit/home/word_cubit.dart';
import 'package:mind_stretch/ui/home/widgets/formatted_text.dart';
import 'package:mind_stretch/ui/widgets/error_illustration.dart';

class WordView extends StatelessWidget {
  const WordView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        BlocBuilder<WordCubit, WordState>(
          buildWhen: (oldState, newState) => oldState != newState,
          builder: (content, state) {
            switch (state) {
              case WordInitial() || WordLoading():
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              case WordLoaded():
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Слово',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            content.read<WordCubit>().refresh();
                          },
                          icon: Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    RepaintBoundary(child: FormattedText(state.word ?? '')),
                  ],
                );
              case WordError():
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Слово',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            content.read<WordCubit>().refresh();
                          },
                          icon: Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    Center(
                      child: ErrorIllustration(
                        error: state.error ?? '',
                        height: 200,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text(state.message)),
                    ),
                  ],
                );
            }
          },
        ),
      ], addSemanticIndexes: false),
    );
  }
}
