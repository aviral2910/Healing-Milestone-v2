import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsSwipeMode extends Notifier<bool> {
  @override
  bool build() => false;
}
final isSwipeModeProvider = NotifierProvider<IsSwipeMode, bool>(IsSwipeMode.new);
