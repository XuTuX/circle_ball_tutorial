import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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
      // 속도가 0에 가까우면 랜덤 방향으로 재설정
      velocity = Vector2(1, 0) * fixedSpeed;
    } else {
      velocity = velocity.normalized() * fixedSpeed;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(_radius, _radius), _radius, _paint..color = color);
  }
}
