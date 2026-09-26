import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    return _isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> loadTheme() async {
    final prefs =
    await SharedPreferences.getInstance();

    _isDarkMode =
        prefs.getBool(_darkModeKey) ?? false;

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _darkModeKey,
      value,
    );

    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }
}