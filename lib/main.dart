import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_stretch/core/theme/app_theme.dart';
import 'package:mind_stretch/logic/scope/app_scope.dart';
import 'package:mind_stretch/ui/home/home_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  runApp(AppScope(child: MindStretch()));
}

class MindStretch extends StatelessWidget {
  const MindStretch({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: AppTheme.lightTheme,
        title: 'Mind Stretch',
        home: const HomePage(),
      ),
    );
  }
}
