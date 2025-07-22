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

  void _handleResetContent() {
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

  void _handleResetSettings() {
    context.read<ContentController>().resetSettings(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(onPressed: _handleRefresh, child: Text('Refresh')),
              Text(
                '* Эта кнопка восстановит контент, если он был утерян на телефоне или настройки изменились.\n'
                'Вы можете обновить конкретный контент вручную, нажав кнопку перезагрузки '
                'в правом верхнем углу на главном экране.',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleResetContent,
                child: Text('Reset'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleResetSettings,
                child: Text('Reset Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
