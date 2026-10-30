import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemePreferenceKey = 'app_theme_mode_preference';

/// Riverpod StateNotifier managing the active application ThemeMode.
/// Supports System Default, Light, and Dark with persistent SharedPreferences storage.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;

  ThemeModeNotifier([this._prefs]) : super(_initialMode(_prefs));

  static ThemeMode _initialMode(SharedPreferences? prefs) {
    if (prefs == null) return ThemeMode.system;
    final saved = prefs.getString(_kThemePreferenceKey);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await prefs.setString(_kThemePreferenceKey, value);
  }
}

/// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main() before runApp()');
});

/// Application theme mode state provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPreferencesProvider);
  } catch (_) {
    // If not overridden yet (e.g. in standalone widget tests), fallback gracefully
  }
  return ThemeModeNotifier(prefs);
});
