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
                      // Антипаттерн в CustomScrollView использовать SliverToBoxAdapter + Column, для этого есть:
                      SliverList(
                        delegate: SliverChildListDelegate.fixed([
                          const Text(
                            'Загадка',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          Text(state.riddle?.riddle ?? ''),
                        ], addSemanticIndexes: false),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate.fixed([
                          const SizedBox(height: 32),
                          const Text(
                            'Слово',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          FormattedText(state.word ?? ''),
                        ]),
                      ),
                      SliverAppBar(
                        pinned: true,
                        title: Text(
                          state.titleArticle ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        centerTitle: false,
                      ),
                      SliverToBoxAdapter(
                        child: Text(state.article?.extract ?? ''),
                      ),
                    ],
                  );
                } else if (state is DailyContentError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 50),
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
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
