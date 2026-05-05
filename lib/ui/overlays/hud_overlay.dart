import 'dart:async';
import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';
import '../../game/models/augment.dart';
import '../../game/utils/game_style.dart';

class HUDOverlay extends StatefulWidget {
  final FastBallGame game;
  const HUDOverlay({super.key, required this.game});

  @override
  State<HUDOverlay> createState() => _HUDOverlayState();
}

class _HUDOverlayState extends State<HUDOverlay> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final topPad = MediaQuery.of(context).padding.top + 8;

    return Stack(
      children: [
        // 상단 왼쪽: 스테이지 정보
        Positioned(
          top: topPad,
          left: 12,
          child: _glassBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.stageDisplay,
                  style: GameStyle.cartoonStyle(fontSize: 22),
                ),
                const SizedBox(height: 2),
                Text(
                  '목표: ${_formatNumber(game.targetScore)}',
                  style: GameStyle.cartoonStyle(fontSize: 13, shadowed: false),
                ),
              ],
            ),
          ),
        ),
        // 상단 오른쪽: 점수 및 시간
        Positioned(
          top: topPad,
          right: 12,
          child: _glassBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNumber(game.score),
                  style: GameStyle.cartoonStyle(fontSize: 28),
                ),
                const SizedBox(height: 2),
                Text(
                  '${game.timeRemaining.isFinite ? game.timeRemaining.clamp(0, 99).toStringAsFixed(1) : "0.0"}초',
                  style: GameStyle.cartoonStyle(
                    fontSize: 18,
                    color: game.timeRemaining < 5 ? GameStyle.primaryRed : GameStyle.inkBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 상단 중앙: 버프 아이콘
        Positioned(
          top: topPad + 4,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (game.activeScoreBuffTimer > 0)
                _buffChip(
                  Icons.stars,
                  '점수x2',
                  const Color(0xFFFFCA28),
                  game.activeScoreBuffTimer,
                ),
              if (game.activeSpeedBuffTimer > 0)
                _buffChip(
                  Icons.bolt,
                  '스피드',
                  const Color(0xFF4FC3F7),
                  game.activeSpeedBuffTimer,
                ),
            ],
          ),
        ),
        // 하단 왼쪽: 보유 증강
        if (game.heldAugmentTitles.isNotEmpty)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 100,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('내 증강'),
                const SizedBox(height: 6),
                ...game.heldAugmentTitles.map((title) {
                  final aug = Augment.allPool.firstWhere(
                    (a) => a.title == title,
                    orElse: () => Augment.allPool.first,
                  );
                  return _augmentBadge(aug);
                }),
              ],
            ),
          ),
        // 하단 오른쪽: 시너지
        if (game.synergyDisplayTexts.isNotEmpty)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 100,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _sectionLabel('시너지'),
                const SizedBox(height: 6),
                ...game.synergyDisplayTexts.map((text) => _synergyBadge(text)),
              ],
            ),
          ),
        // 하단 중앙: 오브 레전드
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 60,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: GameStyle.paperPanelDecoration,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _miniOrb(GameStyle.primaryBlue, 'S'),
                  const SizedBox(width: 14),
                  _miniOrb(GameStyle.primaryYellow, '★'),
                  const SizedBox(width: 14),
                  _miniOrb(GameStyle.primaryGreen, 'T'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: GameStyle.paperPanelDecoration,
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: GameStyle.inkBlack,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _augmentBadge(Augment aug) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: GameStyle.paperBackground,
        border: Border.all(color: GameStyle.inkBlack, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(aug.icon, size: 14, color: GameStyle.inkBlack),
          const SizedBox(width: 6),
          Text(
            aug.title,
            style: GameStyle.cartoonStyle(fontSize: 12, shadowed: false),
          ),
        ],
      ),
    );
  }

  Widget _synergyBadge(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: GameStyle.primaryBlue.withAlpha(100),
        border: Border.all(color: GameStyle.inkBlack, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: GameStyle.inkBlack),
          const SizedBox(width: 6),
          Text(
            text,
            style: GameStyle.cartoonStyle(fontSize: 11, shadowed: false),
          ),
        ],
      ),
    );
  }

  Widget _buffChip(IconData icon, String label, Color color, double timer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: GameStyle.inkBlack, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: GameStyle.inkBlack, size: 14),
          const SizedBox(width: 4),
          Text(
            timer.isFinite ? timer.clamp(0, 99).toStringAsFixed(1) : "0.0",
            style: GameStyle.cartoonStyle(fontSize: 12, shadowed: false),
          ),
        ],
      ),
    );
  }

  Widget _miniOrb(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: GameStyle.inkBlack, width: 1.5),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GameStyle.cartoonStyle(fontSize: 10, shadowed: false),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}k';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
