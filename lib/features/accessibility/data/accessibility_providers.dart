import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// To access sharedPreferencesProvider

class AccessibilityState {
  final double textSizeFactor;
  final double textOpacity;
  final bool isGreyscaleMode;
  final bool showGreyscaleFloatingIcon;
  final double floatingIconDx;
  final double floatingIconDy;

  AccessibilityState({
    this.textSizeFactor = 1.0,
    this.textOpacity = 1.0,
    this.isGreyscaleMode = false,
    this.showGreyscaleFloatingIcon = false, // Disabled for FTUX
    this.floatingIconDx = -1.0, // Indicates not set
    this.floatingIconDy = -1.0,
  });

  AccessibilityState copyWith({
    double? textSizeFactor,
    double? textOpacity,
    bool? isGreyscaleMode,
    bool? showGreyscaleFloatingIcon,
    double? floatingIconDx,
    double? floatingIconDy,
  }) {
    return AccessibilityState(
      textSizeFactor: textSizeFactor ?? this.textSizeFactor,
      textOpacity: textOpacity ?? this.textOpacity,
      isGreyscaleMode: isGreyscaleMode ?? this.isGreyscaleMode,
      showGreyscaleFloatingIcon: showGreyscaleFloatingIcon ?? this.showGreyscaleFloatingIcon,
      floatingIconDx: floatingIconDx ?? this.floatingIconDx,
      floatingIconDy: floatingIconDy ?? this.floatingIconDy,
    );
  }
}

class AccessibilityNotifier extends StateNotifier<AccessibilityState> {
  final SharedPreferences _prefs;
  static const String _greyscaleKey = 'isGreyscaleMode';
  static const String _floatingIconKey = 'showGreyscaleFloatingIcon';
  static const String _floatingIconDxKey = 'floatingIconDx';
  static const String _floatingIconDyKey = 'floatingIconDy';

  AccessibilityNotifier(this._prefs) : super(AccessibilityState()) {
    _loadState();
  }

  void _loadState() {
    final isGreyscale = _prefs.getBool(_greyscaleKey) ?? false;
    final showFloatingIcon = _prefs.getBool(_floatingIconKey) ?? false;
    final dx = _prefs.getDouble(_floatingIconDxKey) ?? -1.0;
    final dy = _prefs.getDouble(_floatingIconDyKey) ?? -1.0;
    
    state = state.copyWith(
      isGreyscaleMode: isGreyscale,
      showGreyscaleFloatingIcon: showFloatingIcon,
      floatingIconDx: dx,
      floatingIconDy: dy,
    );
  }

  void updateTextSizeFactor(double factor) {
    state = state.copyWith(textSizeFactor: factor);
  }

  void updateTextOpacity(double opacity) {
    state = state.copyWith(textOpacity: opacity);
  }

  void toggleGreyscaleMode() {
    final newValue = !state.isGreyscaleMode;
    // Auto-enable the floating icon when user interacts with reading mode
    final newShowFloating = true; 
    
    state = state.copyWith(
      isGreyscaleMode: newValue,
      showGreyscaleFloatingIcon: newShowFloating,
    );
    _prefs.setBool(_greyscaleKey, newValue);
    _prefs.setBool(_floatingIconKey, newShowFloating);
  }

  void toggleFloatingIcon([bool? value]) {
    final newValue = value ?? !state.showGreyscaleFloatingIcon;
    state = state.copyWith(showGreyscaleFloatingIcon: newValue);
    _prefs.setBool(_floatingIconKey, newValue);
  }

  void updateFloatingIconPosition(double dx, double dy) {
    state = state.copyWith(floatingIconDx: dx, floatingIconDy: dy);
    _prefs.setDouble(_floatingIconDxKey, dx);
    _prefs.setDouble(_floatingIconDyKey, dy);
  }
}

final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilityState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccessibilityNotifier(prefs);
});
