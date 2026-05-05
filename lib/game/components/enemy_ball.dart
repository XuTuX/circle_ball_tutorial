import 'package:flutter/material.dart';
import 'ball.dart';

import '../utils/game_style.dart';

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
         color: isBoss ? GameStyle.primaryBlue : GameStyle.primaryGreen,
       ) {
    _textPainter = TextPainter(textDirection: TextDirection.ltr);
    _updateTextPainter();
  }

  void _updateTextPainter() {
    _textPainter.text = TextSpan(
      text: '$_hp',
      style: GameStyle.cartoonStyle(
        fontSize: isBoss ? 24 : 12,
        color: Colors.white,
      ),
    );
    _textPainter.layout();
  }

  void _updateColor() {
    if (!isBoss) {
      color = [
        GameStyle.primaryRed,    // HP 0
        GameStyle.primaryRed,    // HP 1
        GameStyle.primaryYellow, // HP 2
        GameStyle.primaryGreen,  // HP 3
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
