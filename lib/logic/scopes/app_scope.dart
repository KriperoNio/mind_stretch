import 'package:flutter/cupertino.dart';
import 'package:mind_stretch/data/repositories/deepseek_repository.dart';
import 'package:mind_stretch/data/repositories/storage_repository.dart';
import 'package:mind_stretch/data/repositories/wikipedia_repository.dart';
import 'package:mind_stretch/logic/api/api_client.dart';
import 'package:mind_stretch/logic/managers/app_manager.dart';
import 'package:mind_stretch/logic/notifiers/day_value_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AppScopeInherited extends InheritedWidget {
  final AppManager appManager;

  const _AppScopeInherited({required super.child, required this.appManager});

  static AppManager of(BuildContext context, {bool listen = false}) {
    final manager = maybeOf(context, listen: listen);
    return ArgumentError.checkNotNull(manager);
  }

  static AppManager? maybeOf(BuildContext context, {bool listen = false}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<_AppScopeInherited>()
          ?.appManager;
    } else {
      return (context
                  .getElementForInheritedWidgetOfExactType<_AppScopeInherited>()
                  ?.widget
              as _AppScopeInherited?)
          ?.appManager;
    }
  }

  @override
  bool updateShouldNotify(_AppScopeInherited oldWidget) {
    return oldWidget.appManager != appManager;
  }
}

class AppScope extends StatefulWidget {
  final Widget child;

  const AppScope({super.key, required this.child});

  @override
  State<AppScope> createState() => _AppScopeState();

  static AppManager managerOf(BuildContext context, {bool listen = false}) =>
      _AppScopeInherited.of(context, listen: listen);
}

class _AppScopeState extends State<AppScope> {
  AppManager? _appManager; // Менеджер приложения (пока может быть null)
  bool _isInitialized = false; // Флаг инициализации

  @override
  void initState() {
    super.initState();
    _initializeManager(); // Начинаем инициализацию
  }

  // Асинхронная инициализация менеджера
  Future<void> _initializeManager() async {
    final apiClient = ApiClient();
    final sharedPreferences = await SharedPreferences.getInstance();
    final dayValueNotifier = DayValueNotifier();

    setState(() {
      _appManager = AppManager(
        storageRepository: StorageRepository(prefs: sharedPreferences),
        wikipediaRepository: WikipediaRepository(apiClient: apiClient),
        deepseekRepository: DeepseekRepository(apiClient: apiClient),
        dayValueNotifier: dayValueNotifier,
        preferences: sharedPreferences,
        apiClient: apiClient,
      );
      _isInitialized = true; // Инициализация завершена.
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return _AppScopeInherited(appManager: _appManager!, child: widget.child);
  }
}
