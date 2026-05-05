import 'dart:async';
import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';

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
    // 0.05초마다 UI 갱신
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
    return Stack(
      children: [
        // 상단 왼쪽: 스테이지 정보
        Positioned(
          top: 40,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STAGE ${game.stageDisplay}',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent)),
              const SizedBox(height: 4),
              Text('GOAL: ${game.targetScore}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ),
        // 상단 오른쪽: 점수 및 시간
        Positioned(
          top: 40,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${game.score}',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(
                  '${game.timeRemaining.isFinite ? game.timeRemaining.clamp(0, 99).toStringAsFixed(1) : "0.0"}s',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: game.timeRemaining < 5
                          ? Colors.redAccent
                          : Colors.white)),
            ],
          ),
        ),
        // 상단 중앙: 활성화된 버프
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (game.activeScoreBuffTimer > 0)
                _buffIcon(
                    Icons.stars, Colors.yellowAccent, game.activeScoreBuffTimer),
              if (game.activeSpeedBuffTimer > 0)
                _buffIcon(Icons.bolt, Colors.redAccent, game.activeSpeedBuffTimer),
            ],
          ),
        ),
        // 하단 왼쪽 위: 활성화된 시너지
        Positioned(
          bottom: 160,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: game.activeSynergies
                .map((synergy) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withAlpha(51),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orangeAccent),
                      ),
                      child: Text('SYNERGY: $synergy',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buffIcon(IconData icon, Color color, double timer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(timer.isFinite ? timer.clamp(0, 99).toStringAsFixed(1) : "0.0",
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
