import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../fast_ball_game.dart';

enum BuffType {
  speed, // 레드
  score, // 옐로우
  time,  // 블루
}

class BuffOrb extends PositionComponent with HasGameReference<FastBallGame> {
  final BuffType type;
  final double radius = 10.0;

  BuffOrb({
    required super.position,
    required this.type,
  }) : super(
          size: Vector2.all(20),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final color = type == BuffType.speed
        ? Colors.redAccent
        : type == BuffType.score
            ? Colors.yellowAccent
            : Colors.blueAccent;

    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
    
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    canvas.drawCircle(Offset(radius, radius), radius * 0.7, Paint()..color = Colors.white.withAlpha(128));
  }

  void onHit() {
    removeFromParent();
  }
}
