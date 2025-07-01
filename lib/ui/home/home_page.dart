import 'package:flutter/material.dart';
import 'package:mind_stretch/data/models/riddle_model.dart';
import 'package:mind_stretch/data/models/wikipedia/responce_model.dart';
import 'package:mind_stretch/logic/scopes/app_scope.dart';
import 'package:mind_stretch/ui/home/widgets/formatted_text.dart';
import 'package:mind_stretch/ui/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final manager = AppScope.managerOf(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ValueListenableBuilder<DateTime>(
        valueListenable: AppScope.managerOf(
          context,
          listen: true,
        ).getDayValueNotifier,
        builder: (context, date, _) {
          final String key = manager.getDayValueNotifier.todayKey;
          return CustomScrollView(
            slivers: [
              // Riddle section
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<Riddle>(
                    future: manager.getStorageRepository.loadRiddle(
                      context: context,
                      key: key,
                    ),
                    builder: (context, snapshot) {
                      return _buildSection(
                        context,
                        title: 'Загадка',
                        content: _buildRiddleContent(snapshot),
                      );
                    },
                  ),
                ),
              ),

              // Word section
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<String>(
                    future: manager.getStorageRepository.loadWord(
                      context: context,
                      key: key,
                    ),
                    builder: (context, snapshot) {
                      return _buildSection(
                        context,
                        title: 'Новое Слово',
                        content: _buildWordContent(snapshot),
                      );
                    },
                  ),
                ),
              ),

              // Article section
              SliverPadding(
                padding: const EdgeInsets.only(top: 16.0),
                sliver: SliverAppBar(
                  pinned: true,
                  expandedHeight: 60.0,
                  flexibleSpace: FutureBuilder<WikiPage>(
                    future: manager.getStorageRepository.loadArticle(
                      context: context,
                      key: key,
                    ),
                    builder: (context, snapshot) {
                      return FlexibleSpaceBar(
                        title: Text(
                          snapshot.hasData ? snapshot.data!.title : 'Ой!',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                        ),
                        centerTitle: true,
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<WikiPage>(
                    future: manager.getStorageRepository.loadArticle(
                      context: context,
                      key: key,
                    ),
                    builder: (context, snapshot) {
                      return _buildWikiContent(snapshot);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildWordContent(AsyncSnapshot<String> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return FormattedText(snapshot.data ?? 'No data available');
  }

  Widget _buildRiddleContent(AsyncSnapshot<Riddle> snapshot) {
    final answerController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Текст загадки
        Text(snapshot.data?.riddle ?? 'No riddle available'),
        SizedBox(height: 16),

        // Поле ввода и кнопка проверки
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: answerController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Твой ответ...',
                  hintText: 'Можешь написать: сдаюсь',
                ),
              ),
            ),
            SizedBox(width: 8),

            ElevatedButton(
              onPressed: () {
                if (snapshot.hasData) {
                  final userAnswer = answerController.text.trim().toLowerCase();
                  final correctAnswerText = snapshot.data!.answer.toLowerCase();

                  if (userAnswer == correctAnswerText) {
                    answerController.text = 'Верно!';
                  } else if (userAnswer == 'сдаюсь') {
                    answerController.text = 'Это же ${snapshot.data!.answer}!';
                  } else if (userAnswer.isNotEmpty) {
                    answerController.text = 'Неа!';
                  }
                }
              },
              child: Text('Проверь'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWikiContent(AsyncSnapshot<WikiPage> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return FormattedText(snapshot.data?.extract ?? 'No article available');
  }
}
