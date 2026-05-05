import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/fast_ball_game.dart';
import 'game/utils/collection_manager.dart';
import 'ui/overlays/hud_overlay.dart';
import 'ui/overlays/upgrade_menu.dart';
import 'ui/overlays/game_over_overlay.dart';
import 'ui/overlays/penalty_alert_overlay.dart';
import 'ui/overlays/encyclopedia_overlay.dart';

import 'game/utils/game_style.dart';

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
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: GameStyle.paperBackground,
      ),
      home: Scaffold(
        backgroundColor: GameStyle.paperBackground,
        body: Shortcuts(
          shortcuts: <ShortcutActivator, Intent>{
            LogicalKeySet(LogicalKeyboardKey.metaLeft): const DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.metaRight): const DoNothingIntent(),
          },
          child: GameWidget<FastBallGame>(
            game: FastBallGame(),
            autofocus: true,
            overlayBuilderMap: {
              'HUD': (context, game) => HUDOverlay(game: game),
              'UpgradeMenu': (context, game) => UpgradeMenuOverlay(game: game),
              'GameOver': (context, game) => GameOverOverlay(game: game),
              'PenaltyAlert': (context, game) => PenaltyAlertOverlay(game: game),
              'Encyclopedia': (context, game) => EncyclopediaOverlay(game: game),
            },
          ),
        ),
      ),
    );
  }
}
