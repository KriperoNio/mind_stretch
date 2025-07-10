import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/controller/content_controller.dart';
import 'package:mind_stretch/logic/scopes/control_content_scope.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _handleRefresh() {
    context.read<ContentController>().refreshContent(
      onComplete: () {
        if (!mounted) return;
        Navigator.pop(context);
      },
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      },
    );
  }

  void _handleReset() {
    context.read<ContentController>().resetContent(
      onComplete: () {
        if (!mounted) return;
        Navigator.pop(context);
      },
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ControlContentScope(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(onPressed: _handleRefresh, child: Text('Refresh')),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _handleReset, child: Text('Reset')),
            ],
          ),
        ),
      ),
    );
  }
}
