import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static const _themeKey = 'app_theme_mode';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedMode = preferences.getString(_themeKey);
    themeMode.value = switch (savedMode) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  static Future<void> setLight() => _setMode(ThemeMode.light, 'light');
  static Future<void> setDark() => _setMode(ThemeMode.dark, 'dark');
  static Future<void> setSystem() => _setMode(ThemeMode.system, 'system');

  static Future<void> _setMode(ThemeMode mode, String storedValue) async {
    themeMode.value = mode;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, storedValue);
  }
}
