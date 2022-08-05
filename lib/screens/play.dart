import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../characters/airplane.dart';
import '../main.dart';
import '../game.dart';

class GamePlay extends StatelessWidget {
  final Airplane airplane;
  const GamePlay({Key? key, required this.airplane}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlyGame game = FlyGame(context, airplane);
    return GameWidget(game: game);
  }
}
