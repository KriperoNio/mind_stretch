import 'package:flutter/material.dart';
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
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: [
                // Riddle section
                FutureBuilder<String>(
                  future: manager.getStorageRepository.loadRiddle(
                    context: context,
                    key: key,
                  ),
                  builder: (context, snapshot) {
                    return Center(child: _buildApiContent(snapshot));
                  },
                ),

                // Word section
                FutureBuilder<String>(
                  future: manager.getStorageRepository.loadWord(
                    context: context,
                    key: key,
                  ),
                  builder: (context, wordSnapshot) {
                    if (wordSnapshot.connectionState != ConnectionState.done) {
                      return CircularProgressIndicator();
                    }

                    // 3. Статья (грузится только после слова)
                    return Column(
                      children: [
                        _buildApiContent(wordSnapshot),
                        FutureBuilder<String>(
                          future: manager.getStorageRepository.loadArticle(
                            snapshot: wordSnapshot,
                            context: context,
                            key: key,
                          ),
                          builder: (context, articleSnapshot) =>
                              _buildApiContent(articleSnapshot),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApiContent(AsyncSnapshot<String> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return SingleChildScrollView(
      child: FormattedText(snapshot.data ?? 'No snapshot available'),
    );
  }
}
