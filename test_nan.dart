void main() {
  double nan = 0.0 / 0.0;
  print("nan clamp: ${nan.clamp(0.0, 1.0)}");
}
