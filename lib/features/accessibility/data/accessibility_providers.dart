import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessibilityState {
  final double textSizeFactor;
  final double textOpacity;

  AccessibilityState({this.textSizeFactor = 1.0, this.textOpacity = 1.0});

  AccessibilityState copyWith({double? textSizeFactor, double? textOpacity}) {
    return AccessibilityState(
      textSizeFactor: textSizeFactor ?? this.textSizeFactor,
      textOpacity: textOpacity ?? this.textOpacity,
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
}

final accessibilityProvider = StateNotifierProvider<AccessibilityNotifier, AccessibilityState>((ref) {
  return AccessibilityNotifier();
});
