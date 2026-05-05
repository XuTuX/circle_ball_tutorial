import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';

import '../../game/utils/game_style.dart';

class GameOverOverlay extends StatelessWidget {
  final FastBallGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: GameStyle.paperPanelDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('GAME OVER',
                style: GameStyle.cartoonStyle(fontSize: 40, color: GameStyle.primaryRed)),
            const SizedBox(height: 16),
            Text('Final Stage: ${game.stageDisplay}',
                style: GameStyle.cartoonStyle(fontSize: 20, shadowed: false)),
            const SizedBox(height: 32),
            
            // Custom Button
            GestureDetector(
              onTap: () => game.resetGame(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: GameStyle.buttonDecoration.copyWith(color: GameStyle.primaryRed),
                child: Text('RETRY',
                    style: GameStyle.cartoonStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => game.overlays.add('Encyclopedia'),
              icon: const Icon(Icons.menu_book, color: GameStyle.inkBlack),
              label: Text('ENCYCLOPEDIA',
                  style: GameStyle.cartoonStyle(fontSize: 14, shadowed: false)),
            ),
          ],
        ),
      ),
    );
  }
}
