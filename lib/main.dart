import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await AppSettingsController.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'RUAS App',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D9488),
              primary: const Color(0xFF0D9488),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D9488),
              primary: const Color(0xFF0D9488),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            useMaterial3: true,
          ),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(settings.fontSizeMultiplier),
              ),
              child: child!,
            );
          },
          initialRoute: "/",
          routes: {'/': (context) => const SplashView()},
        );
      },
    );
  }
}
