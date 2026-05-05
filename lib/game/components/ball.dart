import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ball extends PositionComponent {
  final double radius;
  final double fixedSpeed;
  final bool isPlayer;

  Color color;
  Vector2 velocity;

  Ball({
    required super.position,
    required this.radius,
    required this.velocity,
    required this.color,
    required this.fixedSpeed,
    this.isPlayer = false,
  }) : super(
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
       );

  double get mass => radius * radius;

  void integrate(double dt) => position += velocity * dt;

  void maintainSpeed() {
    if (velocity.isZero()) return;
    velocity = velocity.normalized() * fixedSpeed;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(radius, radius), radius, Paint()..color = color);
  }
}
