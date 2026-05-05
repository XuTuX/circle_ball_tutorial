import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../utils/game_style.dart';

class Ball extends PositionComponent {
  double _radius;
  double get radius => _radius;
  set radius(double value) {
    _radius = value;
    size = Vector2.all(_radius * 2);
  }

  double fixedSpeed;
  final bool isPlayer;

  Color color;
  Vector2 velocity;
  double mass;

  final Paint _paint = Paint();
  final Paint _outlinePaint = GameStyle.inkOutlinePaint(3);

  Ball({
    required super.position,
    required double radius,
    required this.velocity,
    required this.color,
    required this.fixedSpeed,
    this.isPlayer = false,
  }) : _radius = radius,
       mass = radius * radius,
       super(size: Vector2.all(radius * 2), anchor: Anchor.center);

  void integrate(double dt) => position += velocity * dt;

  void maintainSpeed() {
    if (fixedSpeed <= 0) return;
    final currentSpeed = velocity.length;
    if (currentSpeed < 0.001) {
      velocity = Vector2(1, 0) * fixedSpeed;
    } else {
      velocity = velocity.normalized() * fixedSpeed;
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(_radius, _radius);

    // 본체 (단색)
    canvas.drawCircle(center, _radius, _paint..color = color);

    // 외곽선 (굵은 잉크)
    canvas.drawCircle(center, _radius, _outlinePaint);

    // 낙서 같은 하이라이트 (짧은 곡선 하나)
    if (_radius > 5) {
      final highlightPaint = GameStyle.inkOutlinePaint(2)..color = Colors.white.withAlpha(180);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: _radius * 0.7),
        -2.0,
        1.0,
        false,
        highlightPaint,
      );
    }
  }
}
