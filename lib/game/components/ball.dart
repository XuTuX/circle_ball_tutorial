import 'dart:ui';
import 'package:flame/components.dart';

class Ball extends PositionComponent {
  final double radius;
  final double fixedSpeed;
  final bool isPlayer;

  Color color;
  Vector2 velocity;

  Ball({
    required Vector2 position,
    required this.radius,
    required this.velocity,
    required this.color,
    required this.fixedSpeed,
    this.isPlayer = false,
  }) : super(
         position: position,
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
       );

  double get mass => radius * radius;

  void integrate(double dt) {
    position += velocity * dt;
  }

  void maintainSpeed() {
    if (velocity.length == 0) return;
    velocity = velocity.normalized() * fixedSpeed;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }
}
