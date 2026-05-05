import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';
import '../../game/models/augment.dart';

import '../../game/utils/game_style.dart';

class UpgradeMenuOverlay extends StatelessWidget {
  final FastBallGame game;
  const UpgradeMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 340,
        decoration: GameStyle.paperPanelDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: GameStyle.primaryYellow,
                border: Border.all(color: GameStyle.inkBlack, width: 3),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: GameStyle.inkBlack,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '스테이지 클리어!',
              style: GameStyle.cartoonStyle(fontSize: 26),
            ),
            const SizedBox(height: 6),
            Text(
              '증강을 선택하세요',
              style: GameStyle.cartoonStyle(fontSize: 14, shadowed: false),
            ),
            const SizedBox(height: 24),

            // 증강 카드들
            ...game.currentAugmentOptions.map(
              (augment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _upgradeCard(
                  augment: augment,
                  onTap: () => game.applyAugment(augment),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upgradeCard({required Augment augment, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: augment.color.withAlpha(40),
          border: Border.all(color: GameStyle.inkBlack, width: 3),
          boxShadow: const [
            BoxShadow(color: GameStyle.inkBlack, offset: Offset(4, 4)),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: augment.color,
                border: Border.all(color: GameStyle.inkBlack, width: 2),
              ),
              child: Icon(augment.icon, color: GameStyle.inkBlack, size: 28),
            ),

            const SizedBox(width: 14),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    augment.title,
                    style: GameStyle.cartoonStyle(fontSize: 18, shadowed: false),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    augment.description,
                    style: GameStyle.cartoonStyle(fontSize: 12, shadowed: false),
                  ),
                ],
              ),
            ),

            // 선택 아이콘
            const Icon(Icons.arrow_forward_ios, color: GameStyle.inkBlack, size: 18),
          ],
        ),
      ),
    );
  }
}
