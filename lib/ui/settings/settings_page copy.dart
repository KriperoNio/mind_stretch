import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/core/storage/keys/settings_key.dart';
import 'package:mind_stretch/logic/bloc/settings_bloc.dart';
import 'package:mind_stretch/ui/settings/widgets/editable_field.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          current is SettingsSuccess || current is SettingsFailure,
      listener: (context, state) {
        switch (state) {
          case SettingsFailure(:final error):
            AppLogger.error(
              '>>> SettingsFailure',
              error: error,
              name: 'SettingsPage',
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final isLoading = state is SettingsLoading;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<SettingsBloc>().add(
                              RefreshContent(),
                            ),
                      child: const Text('Обновить весь контент'),
                    ),
                    const Text(
                      '* Эта кнопка восстановит контент, если он был утерян на телефоне или настройки изменились.\n'
                      'Вы можете обновить конкретный контент вручную, нажав кнопку перезагрузки '
                      'в правом верхнем углу на главном экране.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<SettingsBloc>().add(
                              ResetContent(),
                            ),
                      child: const Text('Сбросить весь контент'),
                    ),
                    const SizedBox(height: 16),
                    EditableField(
                      isLoading: isLoading,
                      label: SettingsKey.article.label,
                      initialValue:
                          context
                              .read<SettingsBloc>()
                              .settingsMap[SettingsKey.article]
                              ?.specificTopic ??
                          '',
                      onSave: (newText) => context.read<SettingsBloc>().add(
                        UpdateSpecificTopic(
                          key: SettingsKey.article,
                          topic: newText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EditableField(
                      isLoading: isLoading,
                      label: SettingsKey.riddle.label,
                      initialValue:
                          context
                              .read<SettingsBloc>()
                              .settingsMap[SettingsKey.riddle]
                              ?.specificTopic ??
                          '',
                      onSave: (newText) => context.read<SettingsBloc>().add(
                        UpdateSpecificTopic(
                          key: SettingsKey.riddle,
                          topic: newText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EditableField(
                      isLoading: isLoading,
                      label: SettingsKey.word.label,
                      initialValue:
                          context
                              .read<SettingsBloc>()
                              .settingsMap[SettingsKey.word]
                              ?.specificTopic ??
                          '',
                      onSave: (newText) => context.read<SettingsBloc>().add(
                        UpdateSpecificTopic(
                          key: SettingsKey.word,
                          topic: newText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<SettingsBloc>().add(
                              ResetSettings(),
                            ),
                      child: const Text('Сбросить все настройки'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
