import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() {
  final AsyncValue<int> a = AsyncValue.data(5);
  print(a.value);
}
