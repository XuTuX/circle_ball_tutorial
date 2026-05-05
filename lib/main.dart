import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/fast_ball_game.dart';
import 'game/models/augment.dart';
import 'game/utils/collection_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CollectionManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: GameWidget<FastBallGame>(
          game: FastBallGame(),
          overlayBuilderMap: {
            'HUD': (context, game) => _HUDOverlay(game: game),
            'UpgradeMenu': (context, game) => _buildUpgradeMenu(game),
            'GameOver': (context, game) => _buildGameOver(game),
            'PenaltyAlert': (context, game) => _buildPenaltyAlert(game),
            'Encyclopedia': (context, game) => _buildEncyclopedia(game),
          },
        ),
      ),
    );
  }

  Widget _buildUpgradeMenu(FastBallGame game) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(217),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orangeAccent, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.orangeAccent.withAlpha(77), blurRadius: 20, spreadRadius: 5),
          ],
        ),
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('STAGE CLEAR!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            const SizedBox(height: 8),
            Text('CHOOSE AN AUGMENT', style: TextStyle(fontSize: 14, letterSpacing: 2, color: Colors.white.withAlpha(153))),
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
                  Text(augment.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(augment.description, style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(153))),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline, color: Colors.orangeAccent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPenaltyAlert(FastBallGame game) {
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
              BoxShadow(color: Colors.redAccent.withAlpha(128), blurRadius: 15, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('BOSS PENALTY ACTIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(game.currentPenalty ?? 'WARNING', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver(FastBallGame game) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('GAME OVER', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 16),
            Text('Final Stage: ${game.stageDisplay}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => game.resetGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, 
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('RETRY', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => game.overlays.add('Encyclopedia'),
              icon: const Icon(Icons.menu_book, color: Colors.orangeAccent),
              label: const Text('ENCYCLOPEDIA', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncyclopedia(FastBallGame game) {
    final discovered = CollectionManager().discoveredAugments;
    final allAugments = Augment.allPool;

    return Center(
      child: Container(
        width: 380,
        height: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(245),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orangeAccent.withAlpha(100), width: 2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('COLLECTION', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                IconButton(
                  onPressed: () => game.overlays.remove('Encyclopedia'),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),
            Expanded(
              child: ListView(
                children: [
                  const Text('AUGMENTS', style: TextStyle(fontSize: 14, color: Colors.white54, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  ...allAugments.map((a) {
                    final isFound = discovered.contains(a.title);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFound ? Colors.white.withAlpha(15) : Colors.white.withAlpha(5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(isFound ? a.icon : Icons.lock, color: isFound ? Colors.orangeAccent : Colors.white24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isFound ? a.title : '???', style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isFound ? Colors.white : Colors.white24,
                                )),
                                if (isFound) Text(a.description, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const Text('SYNERGIES', style: TextStyle(fontSize: 14, color: Colors.white54, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  ...CollectionManager().discoveredSynergies.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orangeAccent.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.orangeAccent),
                        const SizedBox(width: 16),
                        Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HUDOverlay extends StatefulWidget {
  final FastBallGame game;
  const _HUDOverlay({required this.game});

  @override
  State<_HUDOverlay> createState() => _HUDOverlayState();
}

class _HUDOverlayState extends State<_HUDOverlay> {
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
              Text('STAGE ${game.stageDisplay}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
              const SizedBox(height: 4),
              Text('GOAL: ${game.targetScore}', style: const TextStyle(fontSize: 16, color: Colors.white70)),
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
              Text('${game.score}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('${game.timeRemaining.toStringAsFixed(1)}s', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, 
                color: game.timeRemaining < 5 ? Colors.redAccent : Colors.white)),
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
                _buffIcon(Icons.stars, Colors.yellowAccent, game.activeScoreBuffTimer),
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
            children: game.activeSynergies.map((synergy) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withAlpha(51),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orangeAccent),
              ),
              child: Text('SYNERGY: $synergy', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            )).toList(),
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
          Text(timer.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
