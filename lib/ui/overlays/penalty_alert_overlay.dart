import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';

class PenaltyAlertOverlay extends StatelessWidget {
  final FastBallGame game;
  const PenaltyAlertOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.redAccent.withAlpha(204),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.redAccent.withAlpha(128),
                  blurRadius: 15,
                  spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('BOSS PENALTY ACTIVE',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(game.currentPenalty ?? 'WARNING',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
