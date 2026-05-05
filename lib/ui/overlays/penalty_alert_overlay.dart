import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';

import '../../game/utils/game_style.dart';

class PenaltyAlertOverlay extends StatelessWidget {
  final FastBallGame game;
  const PenaltyAlertOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          decoration: GameStyle.paperPanelDecoration.copyWith(
            color: GameStyle.primaryRed,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('BOSS PENALTY ACTIVE',
                  style: GameStyle.cartoonStyle(fontSize: 12, color: Colors.white, shadowed: false)),
              const SizedBox(height: 6),
              Text(game.currentPenalty ?? 'WARNING',
                  style: GameStyle.cartoonStyle(fontSize: 24, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
