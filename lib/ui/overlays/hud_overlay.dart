import 'dart:async';
import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';
import '../../game/models/augment.dart';

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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF37474F),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '목표: ${_formatNumber(game.targetScore)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
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
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF37474F),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${game.timeRemaining.isFinite ? game.timeRemaining.clamp(0, 99).toStringAsFixed(1) : "0.0"}초',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: game.timeRemaining < 5
                        ? const Color(0xFFE53935)
                        : const Color(0xFF546E7A),
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
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _miniOrb(const Color(0xFF4FC3F7), 'S'),
                  const SizedBox(width: 14),
                  _miniOrb(const Color(0xFFFFCA28), '★'),
                  const SizedBox(width: 14),
                  _miniOrb(const Color(0xFF4DB6AC), 'T'),
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
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4)],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF78909C),
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
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: aug.color.withAlpha(120)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(aug.icon, size: 14, color: aug.color),
          const SizedBox(width: 6),
          Text(
            aug.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
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
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCE93D8).withAlpha(180)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: Color(0xFFAB47BC)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6A1B9A),
            ),
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
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(150)),
        boxShadow: [BoxShadow(color: color.withAlpha(50), blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            timer.isFinite ? timer.clamp(0, 99).toStringAsFixed(1) : "0.0",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
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
