import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_palette.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

class ThemeNotifier extends Notifier<ThemePalette> {
  static const String _themeKey = 'selected_theme';

  @override
  ThemePalette build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedThemeIndex = prefs.getInt(_themeKey);
    
    if (savedThemeIndex != null && savedThemeIndex >= 0 && savedThemeIndex < AppThemeType.values.length) {
      final type = AppThemeType.values[savedThemeIndex];
      return ThemePalette.allThemes.firstWhere((t) => t.type == type, orElse: () => ThemePalette.goldenDark);
    }
    
    return ThemePalette.goldenDark; // Default theme
  }

  void setTheme(ThemePalette newTheme) {
    state = newTheme;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setInt(_themeKey, newTheme.type.index);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemePalette>(() {
  return ThemeNotifier();
});
