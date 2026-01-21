import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppThemeMode { light, dark, system }

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox<String>(_boxName);
    final savedTheme = box.get(_themeKey, defaultValue: 'system');
    state = _parseThemeMode(savedTheme!);
  }

  Future<void> setTheme(AppThemeMode mode) async {
    final box = await Hive.openBox<String>(_boxName);
    switch (mode) {
      case AppThemeMode.light:
        state = ThemeMode.light;
        await box.put(_themeKey, 'light');
        break;
      case AppThemeMode.dark:
        state = ThemeMode.dark;
        await box.put(_themeKey, 'dark');
        break;
      case AppThemeMode.system:
        state = ThemeMode.system;
        await box.put(_themeKey, 'system');
        break;
    }
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  AppThemeMode get currentAppThemeMode {
    switch (state) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }
}
