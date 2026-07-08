import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final double fontSizeMultiplier;
  final String languageCode;

  AppSettings({
    required this.themeMode,
    required this.fontSizeMultiplier,
    required this.languageCode,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontSizeMultiplier,
    String? languageCode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class AppSettingsController {
  static final AppSettingsController instance = AppSettingsController._();
  AppSettingsController._();

  final ValueNotifier<AppSettings> settingsNotifier = ValueNotifier<AppSettings>(
    AppSettings(
      themeMode: ThemeMode.light,
      fontSizeMultiplier: 1.0,
      languageCode: 'id',
    ),
  );

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    final fontSizeMultiplier = prefs.getDouble('font_size_multiplier') ?? 1.0;
    final language = prefs.getString('language_code') ?? 'id';

    settingsNotifier.value = AppSettings(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      fontSizeMultiplier: fontSizeMultiplier,
      languageCode: language,
    );
  }

  Future<void> updateTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', mode == ThemeMode.dark);
    settingsNotifier.value = settingsNotifier.value.copyWith(themeMode: mode);
  }

  Future<void> updateFontSize(double multiplier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size_multiplier', multiplier);
    settingsNotifier.value = settingsNotifier.value.copyWith(fontSizeMultiplier: multiplier);
  }

  Future<void> updateLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    settingsNotifier.value = settingsNotifier.value.copyWith(languageCode: code);
  }
}

