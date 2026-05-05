import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';
import '../../game/models/augment.dart';
import '../../game/utils/collection_manager.dart';

class EncyclopediaOverlay extends StatelessWidget {
  final FastBallGame game;
  const EncyclopediaOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
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
                const Text('COLLECTION',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent)),
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
                  const Text('AUGMENTS',
                      style: TextStyle(
                          fontSize: 14, color: Colors.white54, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  ...allAugments.map((a) {
                    final isFound = discovered.contains(a.title);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFound
                            ? Colors.white.withAlpha(15)
                            : Colors.white.withAlpha(5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(isFound ? a.icon : Icons.lock,
                              color: isFound ? Colors.orangeAccent : Colors.white24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isFound ? a.title : '???',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isFound ? Colors.white : Colors.white24,
                                    )),
                                if (isFound)
                                  Text(a.description,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const Text('SYNERGIES',
                      style: TextStyle(
                          fontSize: 14, color: Colors.white54, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  ...CollectionManager().discoveredSynergies.map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.orangeAccent.withAlpha(50)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome,
                                color: Colors.orangeAccent),
                            const SizedBox(width: 16),
                            Text(s,
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold)),
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
