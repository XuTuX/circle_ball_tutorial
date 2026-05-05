import 'package:flutter/material.dart';
import '../../game/fast_ball_game.dart';
import '../../game/models/augment.dart';
import '../../game/utils/collection_manager.dart';

import '../../game/utils/game_style.dart';

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
        decoration: GameStyle.paperPanelDecoration,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('COLLECTION',
                    style: GameStyle.cartoonStyle(fontSize: 24, color: GameStyle.primaryOrange)),
                IconButton(
                  onPressed: () => game.overlays.remove('Encyclopedia'),
                  icon: const Icon(Icons.close, color: GameStyle.inkBlack),
                ),
              ],
            ),
            const Divider(color: GameStyle.inkBlack, thickness: 2, height: 32),
            Expanded(
              child: ListView(
                children: [
                  Text('AUGMENTS',
                      style: GameStyle.cartoonStyle(fontSize: 14, shadowed: false)),
                  const SizedBox(height: 16),
                  ...allAugments.map((a) {
                    final isFound = discovered.contains(a.title);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFound ? GameStyle.primaryYellow.withAlpha(50) : Colors.transparent,
                        border: Border.all(color: GameStyle.inkBlack, width: isFound ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(isFound ? a.icon : Icons.lock,
                              color: GameStyle.inkBlack),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isFound ? a.title : '???',
                                    style: GameStyle.cartoonStyle(fontSize: 14, shadowed: false)),
                                if (isFound)
                                  Text(a.description,
                                      style: GameStyle.cartoonStyle(fontSize: 11, shadowed: false)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Text('SYNERGIES',
                      style: GameStyle.cartoonStyle(fontSize: 14, shadowed: false)),
                  const SizedBox(height: 16),
                  ...CollectionManager().discoveredSynergies.map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GameStyle.primaryBlue.withAlpha(50),
                          border: Border.all(color: GameStyle.inkBlack, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: GameStyle.inkBlack),
                            const SizedBox(width: 16),
                            Text(s, style: GameStyle.cartoonStyle(fontSize: 14, shadowed: false)),
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
