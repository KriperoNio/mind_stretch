import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/cubit/riddle_cubit.dart';
import 'package:mind_stretch/ui/widgets/error_illustration.dart';

class RiddleView extends StatelessWidget {
  const RiddleView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        BlocBuilder<RiddleCubit, RiddleState>(
          buildWhen: (oldState, newState) => oldState != newState,
          builder: (content, state) {
            switch (state) {
              case RiddleInitial() || RiddleLoading():
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              case RiddleLoaded():
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Загадка',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          softWrap: true,
                        ),
                        IconButton(
                          onPressed: () {
                            content.read<RiddleCubit>().refresh();
                          },
                          icon: Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    RepaintBoundary(child: Text(state.riddle?.riddle ?? '')),
                  ],
                );
              case RiddleError():
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Загадка',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          softWrap: true,
                        ),
                        IconButton(
                          onPressed: () {
                            content.read<RiddleCubit>().refresh();
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
