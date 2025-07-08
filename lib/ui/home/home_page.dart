import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/bloc/daily_content_bloc.dart';
import 'package:mind_stretch/ui/home/widgets/formatted_text.dart';
import 'package:mind_stretch/ui/settings/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () => goSettings(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RepaintBoundary(
            child: BlocBuilder<DailyContentBloc, DailyContentState>(
              builder: (context, state) {
                if (state is DailyContentLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is DailyContentLoaded) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Загадка',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                            FormattedText(state.riddle?.riddle ?? ''),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const Center(
                              child: Text(
                                'Слово',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                            FormattedText(state.word ?? ''),
                          ],
                        ),
                      ),
                      SliverAppBar(
                        title: Text(state.titleArticle ?? ''),
                        pinned: true,
                      ),
                      SliverToBoxAdapter(
                        child: FormattedText(state.article?.extract ?? ''),
                      ),
                    ],
                  );
                } else {
                  return Placeholder();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void goSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }
}
