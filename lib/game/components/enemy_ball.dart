import 'package:flutter/material.dart';
import 'ball.dart';

class EnemyBall extends Ball {
  int _hp = 3;
  int get hp => _hp;
  set hp(int value) {
    _hp = value;
    _updateTextPainter();
    _updateColor();
  }

  final double hitCooldownDuration;
  double hitCooldown = 0;
  bool isBoss;

  late TextPainter _textPainter;

  bool get isDead => _hp <= 0;
  bool get canTakeDamage => hitCooldown <= 0;

  EnemyBall({
    required super.position,
    required super.radius,
    required super.velocity,
    required super.fixedSpeed,
    required this.hitCooldownDuration,
    this.isBoss = false,
  }) : super(
         color: isBoss ? const Color(0xFF7E57C2) : const Color(0xFF66BB6A),
       ) {
    _textPainter = TextPainter(textDirection: TextDirection.ltr);
    _updateTextPainter();
  }

  void _updateTextPainter() {
    _textPainter.text = TextSpan(
      text: '$_hp',
      style: TextStyle(
        color: isBoss ? Colors.white : Colors.white,
        fontSize: isBoss ? 20 : 9,
        fontWeight: FontWeight.bold,
      ),
    );
    _textPainter.layout();
  }

  void _updateColor() {
    if (!isBoss) {
      color = [
        const Color(0xFFEF5350), // 빨강 (HP 0)
        const Color(0xFFEF5350), // 빨강 (HP 1)
        const Color(0xFFFFCA28), // 노랑 (HP 2)
        const Color(0xFF66BB6A), // 초록 (HP 3)
      ][_hp.clamp(0, 3)];
    }
  }

  void tickCooldown(double dt) {
    if (hitCooldown > 0) hitCooldown -= dt;
  }

  void takeDamage() {
    if (!canTakeDamage) return;
    hp--;
    hitCooldown = hitCooldownDuration;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _textPainter.paint(
      canvas,
      Offset(radius - _textPainter.width / 2, radius - _textPainter.height / 2),
    );
  }
}
