import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ArenaComponent extends Component {
  final Vector2 center;
  final double radius;

  final Paint _bgPaint = Paint()..color = const Color(0xFFF0F4F8);
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFFB0BEC5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  final Paint _innerGlowPaint = Paint()
    ..color = const Color(0x1A90CAF9)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

  ArenaComponent({required this.center, required this.radius});

  @override
  void render(Canvas canvas) {
    // 바깥 글로우
    canvas.drawCircle(center.toOffset(), radius + 8, _innerGlowPaint);
    // 배경
    canvas.drawCircle(center.toOffset(), radius, _bgPaint);
    // 테두리
    canvas.drawCircle(center.toOffset(), radius, _borderPaint);
  }
}
