import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../utils/game_style.dart';

class ArenaComponent extends Component {
  final Vector2 center;
  final double radius;

  final Paint _bgPaint = Paint()..color = GameStyle.paperBackground;
  final Paint _borderPaint = GameStyle.inkOutlinePaint(6);

  ArenaComponent({required this.center, required this.radius});

  @override
  void render(Canvas canvas) {
    // 배경 (종이 느낌)
    canvas.drawCircle(center.toOffset(), radius, _bgPaint);
    
    // 테두리 (굵은 잉크 외곽선)
    canvas.drawCircle(center.toOffset(), radius, _borderPaint);

    // 낙서 같은 장식 (옵션)
    final decoPaint = GameStyle.inkOutlinePaint(1)..color = GameStyle.inkBlack.withAlpha(40);
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(center.toOffset(), radius * (0.2 + i * 0.15), decoPaint);
    }
  }
}
