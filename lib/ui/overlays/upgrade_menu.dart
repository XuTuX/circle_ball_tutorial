import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';
import '../../game/models/augment.dart';

class UpgradeMenuOverlay extends StatelessWidget {
  final FastBallGame game;
  const UpgradeMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(217),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orangeAccent, width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.orangeAccent.withAlpha(77),
                blurRadius: 20,
                spreadRadius: 5),
          ],
        ),
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('STAGE CLEAR!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent)),
            const SizedBox(height: 8),
            Text('CHOOSE AN AUGMENT',
                style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    color: Colors.white.withAlpha(153))),
            const SizedBox(height: 24),
            // 무작위로 생성된 3개의 증강 카드 표시
            ...game.currentAugmentOptions.map((augment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _upgradeButton(
                    augment: augment,
                    onTap: () => game.applyAugment(augment),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _upgradeButton({required Augment augment, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(augment.icon, color: Colors.orangeAccent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(augment.title,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(augment.description,
                      style:
                          TextStyle(fontSize: 13, color: Colors.white.withAlpha(153))),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline,
                color: Colors.orangeAccent, size: 20),
          ],
        ),
      ),
    );
  }
}
