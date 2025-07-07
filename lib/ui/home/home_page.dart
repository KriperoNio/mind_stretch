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
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  onPressed: goSettings,
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomScrollView(
                  controller: _controller,
                  slivers: [
                    const SliverAppBar(title: Center(child: Text('Загадка'))),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Text(state.riddle?.riddle ?? '')],
                      ),
                    ),
                    const SliverAppBar(title: Center(child: Text('Слово'))),
                    SliverToBoxAdapter(child: FormattedText(state.word ?? '')),
                    SliverAppBar(
                      title: Center(child: Text(state.titleArticle ?? '')),
                      pinned: true,
                    ),
                    SliverToBoxAdapter(
                      child: FormattedText(state.article?.extract ?? ''),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Placeholder();
        }
      },
    );
  }

  void goSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }
}
