import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/bloc/daily_content_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyContentBloc, DailyContentState>(
      builder: (context, state) {
        if (state is DailyContentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DailyContentLoaded) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(onPressed: () {
              context.read<DailyContentBloc>().add(DailyContentForceReset());
            }, child: Icon(Icons.replay_rounded),),
            appBar: AppBar(),
            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Загадка: ${state.riddle?.riddle ?? 'Загрузка...'}'),
                    Text('Слово дня: ${state.word ?? 'Загрузка...'}'),
                    Text('Статья: ${state.article?.title ?? 'Загрузка...'}'),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(state.article?.extract! ?? 'Загрузка...'),
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
    );
  }
}
