import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// To access sharedPreferencesProvider

class AccessibilityState {
  final double textSizeFactor;
  final double textOpacity;
  final bool isGreyscaleMode;

  AccessibilityState({
    this.textSizeFactor = 1.0,
    this.textOpacity = 1.0,
    this.isGreyscaleMode = false,
  });

  AccessibilityState copyWith({
    double? textSizeFactor,
    double? textOpacity,
    bool? isGreyscaleMode,
  }) {
    return AccessibilityState(
      textSizeFactor: textSizeFactor ?? this.textSizeFactor,
      textOpacity: textOpacity ?? this.textOpacity,
      isGreyscaleMode: isGreyscaleMode ?? this.isGreyscaleMode,
    );
  }
}

class AccessibilityNotifier extends StateNotifier<AccessibilityState> {
  final SharedPreferences _prefs;
  static const String _greyscaleKey = 'isGreyscaleMode';

  AccessibilityNotifier(this._prefs) : super(AccessibilityState()) {
    _loadState();
  }

  void _loadState() {
    final isGreyscale = _prefs.getBool(_greyscaleKey) ?? false;
    state = state.copyWith(isGreyscaleMode: isGreyscale);
  }

  void updateTextSizeFactor(double factor) {
    state = state.copyWith(textSizeFactor: factor);
  }

  void updateTextOpacity(double opacity) {
    state = state.copyWith(textOpacity: opacity);
  }

  void toggleGreyscaleMode() {
    final newValue = !state.isGreyscaleMode;
    state = state.copyWith(isGreyscaleMode: newValue);
    _prefs.setBool(_greyscaleKey, newValue);
  }
}

final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilityState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccessibilityNotifier(prefs);
});
