import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ArenaComponent extends Component {
  final Vector2 center;
  final double radius;

  ArenaComponent({required this.center, required this.radius});

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(center.toOffset(), radius, Paint()..color = const Color(0xFF111827));
    canvas.drawCircle(
      center.toOffset(),
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
