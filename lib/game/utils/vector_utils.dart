import 'dart:math';
import 'package:flame/extensions.dart';

Vector2 rotateVector(Vector2 v, double angle) {
  final cosA = cos(angle);
  final sinA = sin(angle);

  return Vector2(v.x * cosA - v.y * sinA, v.x * sinA + v.y * cosA);
}
