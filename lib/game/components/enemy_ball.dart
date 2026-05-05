import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'ball.dart';

class EnemyBall extends Ball {
  int hp = 3;
  final double hitCooldownDuration;
  double hitCooldown = 0;

  bool get isDead => hp <= 0;

  EnemyBall({
    required super.position,
    required super.radius,
    required super.velocity,
    required super.fixedSpeed,
    required this.hitCooldownDuration,
  }) : super(
         color: Colors.greenAccent,
       );

  bool get canTakeDamage => hitCooldown <= 0;

  void tickCooldown(double dt) {
    if (hitCooldown > 0) {
      hitCooldown -= dt;
    }
  }

  void takeDamage() {
    if (!canTakeDamage) return;

    hp -= 1;
    hitCooldown = hitCooldownDuration;

    _updateColor();
  }

  void _updateColor() {
    if (hp == 3) {
      color = Colors.greenAccent;
    } else if (hp == 2) {
      color = Colors.yellowAccent;
    } else if (hp == 1) {
      color = Colors.redAccent;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textPainter = TextPainter(
      text: TextSpan(
        text: hp.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );
  }
}
