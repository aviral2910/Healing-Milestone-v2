import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  AccessibilityNotifier() : super(AccessibilityState());

  void updateTextSizeFactor(double factor) {
    state = state.copyWith(textSizeFactor: factor);
  }

  void updateTextOpacity(double opacity) {
    state = state.copyWith(textOpacity: opacity);
  }

  void toggleGreyscaleMode() {
    state = state.copyWith(isGreyscaleMode: !state.isGreyscaleMode);
  }
}

final accessibilityProvider = StateNotifierProvider<AccessibilityNotifier, AccessibilityState>((ref) {
  return AccessibilityNotifier();
});
