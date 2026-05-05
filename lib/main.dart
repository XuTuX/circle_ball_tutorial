import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/fast_ball_game.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: FastBallGame(),
        ),
      ),
    ),
  );
}
