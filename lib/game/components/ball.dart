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

  Ball({
    required super.position,
    required double radius,
    required this.velocity,
    required this.color,
    required this.fixedSpeed,
    this.isPlayer = false,
  })  : _radius = radius,
        mass = radius * radius,
        super(
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        );

  void integrate(double dt) => position += velocity * dt;

  void maintainSpeed() {
    if (velocity.isZero()) return;
    velocity = velocity.normalized() * fixedSpeed;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(_radius, _radius), _radius, Paint()..color = color);
  }
}
