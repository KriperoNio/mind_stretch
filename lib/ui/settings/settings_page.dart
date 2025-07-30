import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/core/storage/keys/settings_key.dart';
import 'package:mind_stretch/logic/bloc/settings/settings_bloc.dart';
import 'package:mind_stretch/logic/cubit/settings/topic_chips_cubit.dart';
import 'package:mind_stretch/ui/settings/widgets/editable_field.dart';
import 'package:mind_stretch/ui/settings/widgets/topic_chips_carousel.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  final isLoading = state is SettingsLoading;

                  return AbsorbPointer(
                    absorbing: isLoading,
                    child: AnimatedOpacity(
                      opacity: isLoading ? 0.4 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () => context.read<SettingsBloc>().add(
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
                              onPressed: () => context.read<SettingsBloc>().add(
                                ResetContent(),
                              ),
                              child: const Text('Сбросить весь контент'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<TopicChipsCubit>()
                                  .resetAndLoad(),
                              child: const Text('Сбросить все чипсы'),
                            ),
                            const SizedBox(height: 8),

                            TopicChipsCarousel(
                              onSelected: (value) {
                                AppLogger.log('>>> $value');
                              },
                            ),

                            _SpecificTopicField(keyType: SettingsKey.article),
                            const SizedBox(height: 16),
                            _SpecificTopicField(keyType: SettingsKey.riddle),
                            const SizedBox(height: 16),
                            _SpecificTopicField(keyType: SettingsKey.word),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<SettingsBloc>().add(
                                ResetSettings(),
                              ),
                              child: const Text('Сбросить все настройки'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              BlocBuilder<SettingsBloc, SettingsState>(
                buildWhen: (prev, curr) =>
                    prev is SettingsLoading != curr is SettingsLoading,
                builder: (context, state) {
                  if (state is SettingsLoading) {
                    return const Positioned.fill(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecificTopicField extends StatelessWidget {
  final SettingsKey keyType;

  const _SpecificTopicField({required this.keyType});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsBloc, SettingsState, String>(
      selector: (state) {
        /// Это обходит сам state, что может привести к тому, что BlocSelector
        /// не заметит изменения (если settingsMap изменился, а state остался
        /// тем же классом — например, SettingsSuccess).
        final map = context.read<SettingsBloc>().settingsMap;
        return map[keyType]?.specificTopic ?? '';
      },
      builder: (context, value) {
        return EditableField(
          label: keyType.label,
          initialValue: value,
          onSave: (newText) {
            context.read<SettingsBloc>().add(
              UpdateSpecificTopic(key: keyType, topic: newText),
            );
          },
        );
      },
    );
  }
}
