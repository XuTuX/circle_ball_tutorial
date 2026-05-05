import 'package:flutter/material.dart';
import 'ball.dart';

class EnemyBall extends Ball {
  int hp = 3;
  final double hitCooldownDuration;
  double hitCooldown = 0;

  bool get isDead => hp <= 0;
  bool get canTakeDamage => hitCooldown <= 0;

  EnemyBall({
    required super.position,
    required super.radius,
    required super.velocity,
    required super.fixedSpeed,
    required this.hitCooldownDuration,
  }) : super(color: Colors.greenAccent);

  void tickCooldown(double dt) {
    if (hitCooldown > 0) hitCooldown -= dt;
  }

  void takeDamage() {
    if (!canTakeDamage) return;
    hp--;
    hitCooldown = hitCooldownDuration;
    color = [Colors.redAccent, Colors.redAccent, Colors.yellowAccent, Colors.greenAccent][hp.clamp(0, 3)];
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final tp = TextPainter(
      text: TextSpan(
        text: '$hp',
        style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(radius - tp.width / 2, radius - tp.height / 2));
  }
}
