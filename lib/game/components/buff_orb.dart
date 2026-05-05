import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../fast_ball_game.dart';

import '../utils/game_style.dart';

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
        ? GameStyle.primaryRed
        : type == BuffType.score
            ? GameStyle.primaryYellow
            : GameStyle.primaryBlue;

    final center = Offset(radius, radius);
    
    // 본체
    canvas.drawCircle(center, radius, Paint()..color = color);
    
    // 외곽선
    canvas.drawCircle(center, radius, GameStyle.inkOutlinePaint(2.5));
    
    // 내부 십자 형태 (약간의 낙서 느낌)
    final crossPaint = GameStyle.inkOutlinePaint(1.5)..color = Colors.white.withAlpha(200);
    canvas.drawLine(Offset(radius, radius - 5), Offset(radius, radius + 5), crossPaint);
    canvas.drawLine(Offset(radius - 5, radius), Offset(radius + 5, radius), crossPaint);
  }

  void onHit() {
    removeFromParent();
  }
}
