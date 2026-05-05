import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: FastBallGame()));
}

class FastBallGame extends FlameGame {
  late Vector2 arenaCenter;
  late double arenaRadius;

  late PhysicsBall ball;

  final Random random = Random();

  final double fixedSpeed = 450;
  final double angleRandomness = 0.35;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    arenaCenter = size / 2;
    arenaRadius = min(size.x, size.y) * 0.42;

    add(ArenaComponent(center: arenaCenter, radius: arenaRadius));

    _spawnBall();
  }

  void _spawnBall() {
    final angle = random.nextDouble() * pi * 2;

    ball = PhysicsBall(
      position: arenaCenter,
      radius: 16,
      velocity: Vector2(cos(angle), sin(angle)) * fixedSpeed,
      color: Colors.orange,
    );

    add(ball);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final safeDt = dt.clamp(0.0, 1 / 60);

    ball.integrate(safeDt);
    _resolveWallCollision(ball);
  }

  void _resolveWallCollision(PhysicsBall ball) {
    final toBall = ball.position - arenaCenter;
    final distance = toBall.length;

    final maxDistance = arenaRadius - ball.radius;

    if (distance > maxDistance) {
      final normal = toBall.normalized();

      ball.position = arenaCenter + normal * maxDistance;

      final dot = ball.velocity.dot(normal);

      if (dot > 0) {
        ball.velocity = ball.velocity - normal * (2 * dot);

        final randomAngle = (random.nextDouble() - 0.5) * angleRandomness;
        ball.velocity = rotateVector(ball.velocity, randomAngle);

        ball.velocity = ball.velocity.normalized() * fixedSpeed;
      }
    }
  }

  Vector2 rotateVector(Vector2 v, double angle) {
    final cosA = cos(angle);
    final sinA = sin(angle);

    return Vector2(v.x * cosA - v.y * sinA, v.x * sinA + v.y * cosA);
  }
}

class ArenaComponent extends Component {
  final Vector2 center;
  final double radius;

  ArenaComponent({required this.center, required this.radius});

  @override
  void render(Canvas canvas) {
    final fillPaint = Paint()
      ..color = const Color(0xFF111827)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(center.x, center.y), radius, fillPaint);

    canvas.drawCircle(Offset(center.x, center.y), radius, strokePaint);
  }
}

class PhysicsBall extends PositionComponent {
  final double radius;
  final Color color;

  Vector2 velocity;

  PhysicsBall({
    required Vector2 position,
    required this.radius,
    required this.velocity,
    required this.color,
  }) : super(
         position: position,
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
       );

  void integrate(double dt) {
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;

    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }
}
