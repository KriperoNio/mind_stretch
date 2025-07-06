import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/bloc/daily_content_bloc.dart';
import 'package:mind_stretch/ui/home/widgets/formatted_text.dart';
import 'package:mind_stretch/ui/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAnswerVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyContentBloc, DailyContentState>(
      builder: (context, state) {
        if (state is DailyContentLoading) {
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is DailyContentLoaded) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  ),
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Загадка',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(child: Text(state.riddle!.riddle.toString())),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isAnswerVisible = !isAnswerVisible;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ответ'),
                                      Icon(
                                        isAnswerVisible
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                      ),
                                    ],
                                  ),
                                  if (isAnswerVisible) ...[
                                    const SizedBox(height: 8),
                                    Text(state.riddle!.answer.toString()),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Слово',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(child: FormattedText(state.word.toString())),
                        ],
                      ),
                    ),
                  ),
                  SliverAppBar(
                    pinned: true,
                    title: Text(
                      maxLines: 2,
                      state.titleArticle?.toString() ?? '',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: FormattedText(state.article?.extract.toString() ?? ''),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ошибка загрузки\n${(state as DailyContentError).message}',
                  ),
                  ElevatedButton(
                    onPressed: () => context.read<DailyContentBloc>().add(
                      DailyContentForceReset(),
                    ),
                    child: Icon(Icons.replay_rounded),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
