import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/logic/cubit/settings_cubit.dart';
import 'package:mind_stretch/ui/settings/widgets/editable_field.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        switch (state) {
          case SettingsSuccess():
            Navigator.pop(context);
          case SettingsFailure(:final error):
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
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              final isLoading = state is SettingsLoading;

              switch (state) {
                case SettingsInitial():
                case SettingsLoading():
                case SettingsSuccess():
                default:
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () =>
                                context.read<SettingsCubit>().refreshContent(),
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
                          : () => context.read<SettingsCubit>().resetContent(),
                      child: const Text('Сбросить весь контент'),
                    ),
                    const SizedBox(height: 16),
                    EditableField(label: 'Статья', isLoading: isLoading),
                    const SizedBox(height: 16),
                    EditableField(label: 'Загадка', isLoading: isLoading),
                    const SizedBox(height: 16),
                    EditableField(label: 'Слово', isLoading: isLoading),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<SettingsCubit>().resetSettings(),
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
