import 'package:flutter/material.dart';
import 'package:mind_stretch/ui/home/widgets/views/article_view.dart';
import 'package:mind_stretch/ui/home/widgets/views/riddle_view.dart';
import 'package:mind_stretch/ui/home/widgets/views/word_view.dart';
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
          child: CustomScrollView(
            slivers: [
              RiddleView(),
              WordView(),
              ArticleView(),
              SliverPadding(padding: EdgeInsetsGeometry.only(bottom: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void goSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }
}
