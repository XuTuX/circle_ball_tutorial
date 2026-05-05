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
        width: 340,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(250),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C6BC0).withAlpha(50),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0).withAlpha(30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF5C6BC0),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '스테이지 클리어!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '증강을 선택하세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),

            // 증강 카드들
            ...game.currentAugmentOptions.map(
              (augment) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: augment.color.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: augment.color.withAlpha(60)),
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: augment.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(augment.icon, color: augment.color, size: 26),
              ),

              const SizedBox(width: 14),
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      augment.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      augment.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // 선택 아이콘
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: augment.color.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: augment.color, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
