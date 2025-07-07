import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/bloc/daily_content_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    void reset() {
      // Закрыть настройки
      Navigator.pop(context);

      // Отправить ивент на сброс
      context.read<DailyContentBloc>().add(DailyContentForceReset());
    }

    void refresh() {
      // Закрыть настройки
      Navigator.pop(context);

      // Отправить ивент на сброс
      context.read<DailyContentBloc>().add(DailyContentRefresh());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: reset,
                label: const Center(child: Text('Сброс данных')),
                icon: const Icon(Icons.clear_all_rounded),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: refresh,
                label: const Center(child: Text('Обновление данных')),
                icon: const Icon(Icons.refresh_sharp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
