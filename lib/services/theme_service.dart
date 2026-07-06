import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {

  static const String key = "theme_mode";

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {

    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(key);

    switch (value) {

      case "light":
        _themeMode = ThemeMode.light;
        break;

      case "dark":
        _themeMode = ThemeMode.dark;
        break;

      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setTheme(
      ThemeMode mode,
      ) async {

    final prefs =
        await SharedPreferences.getInstance();

    _themeMode = mode;

    switch (mode) {

      case ThemeMode.light:
        await prefs.setString(key, "light");
        break;

      case ThemeMode.dark:
        await prefs.setString(key, "dark");
        break;

      case ThemeMode.system:
        await prefs.setString(key, "system");
        break;
    }

    notifyListeners();
  }
}