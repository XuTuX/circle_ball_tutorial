import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../utils/game_style.dart';

class DamageText extends TextComponent with HasGameReference, HasPaint implements OpacityProvider {
  DamageText({
    required String text,
    required Vector2 position,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
        );

  @override
  double get opacity => paint.color.a;

  @override
  set opacity(double value) {
    paint.color = paint.color.withValues(alpha: value);
  }

  @override
  Future<void> onLoad() async {
    textRenderer = TextPaint(
      style: GameStyle.cartoonStyle(fontSize: 32, color: GameStyle.primaryRed),
    );
    
    // Simple animation: move up and fade out
    add(MoveByEffect(
      Vector2(0, -50),
      EffectController(duration: 0.6, curve: Curves.easeOut),
    ));
    add(OpacityEffect.to(
      0.0,
      EffectController(duration: 0.6, curve: Curves.easeIn),
      onComplete: () => removeFromParent(),
    ));
  }

  @override
  void render(Canvas canvas) {
    // HasPaint의 paint(OpacityEffect가 수정함)를 적용하기 위해 saveLayer 사용
    canvas.saveLayer(size.toRect(), paint);
    super.render(canvas);
    canvas.restore();
  }
}
