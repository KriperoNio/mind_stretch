import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/controller/content_controller.dart';
import 'package:mind_stretch/logic/cubit/settings_cubit.dart';
import 'package:mind_stretch/logic/scopes/control_content_scope.dart';
import 'package:mind_stretch/ui/settings/widgets/editable_field.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ControlContentScope(
      child: BlocProvider(
        create: (_) =>
            SettingsCubit(contentController: context.read<ContentController>()),
        child: const _SettingsView(),
      ),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final _articleSettingsController = TextEditingController();
  final _riddleSettingsController = TextEditingController();
  final _wordSettingsController = TextEditingController();

  bool _fieldArticleEditable = false;
  bool _fieldRiddleEditable = false;
  bool _fieldWordEditable = false;

  @override
  void dispose() {
    _articleSettingsController.dispose();
    _riddleSettingsController.dispose();
    _wordSettingsController.dispose();
    super.dispose();
  }

  void _reverseText(TextEditingController controller) {
    final text = controller.text;
    controller.text = text.split('').reversed.join();
  }

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

                    EditableField(
                      label: 'Статья',
                      controller: _articleSettingsController,
                      isEditable: _fieldArticleEditable,
                      isLoading: isLoading,
                      onEditToggle: (val) {
                        setState(() => _fieldArticleEditable = val);
                      },
                      onReverse: () => _reverseText(_articleSettingsController),
                    ),
                    const SizedBox(height: 16),

                    EditableField(
                      label: 'Загадка',
                      controller: _riddleSettingsController,
                      isEditable: _fieldRiddleEditable,
                      isLoading: isLoading,
                      onEditToggle: (val) {
                        setState(() => _fieldRiddleEditable = val);
                      },
                      onReverse: () => _reverseText(_riddleSettingsController),
                    ),
                    const SizedBox(height: 16),

                    EditableField(
                      label: 'Слово',
                      controller: _wordSettingsController,
                      isEditable: _fieldWordEditable,
                      isLoading: isLoading,
                      onEditToggle: (val) {
                        setState(() => _fieldWordEditable = val);
                      },
                      onReverse: () => _reverseText(_wordSettingsController),
                    ),

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
