import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'app_theme_mode';

  ThemeMode selectedThemeMode = ThemeMode.system;

  ThemeMode get themeMode => selectedThemeMode;

  String get themeModeLabel {
    switch (selectedThemeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeKey);

    switch (savedMode) {
      case 'light':
        selectedThemeMode = ThemeMode.light;
        break;
      case 'dark':
        selectedThemeMode = ThemeMode.dark;
        break;
      default:
        selectedThemeMode = ThemeMode.system;
    }
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    selectedThemeMode = mode;

    final prefs = await SharedPreferences.getInstance();

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await prefs.setString(_themeKey, value);

    Get.changeThemeMode(mode);
    update();
  }
}
