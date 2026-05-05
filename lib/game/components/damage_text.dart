import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../utils/game_style.dart';

class DamageText extends TextComponent with HasGameReference {
  DamageText({
    required String text,
    required Vector2 position,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
        );

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
}
