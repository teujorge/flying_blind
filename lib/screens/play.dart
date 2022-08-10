import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game.dart';
import '../characters/airplane.dart';

class GamePlay extends StatelessWidget {
  final Airplane airplane;
  const GamePlay({Key? key, required this.airplane}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlyGame game = FlyGame(context, airplane);

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            game.throttleStick,
          ],
        ),
      ),
    );
  }
}

class ThrottleStick extends StatefulWidget {
  final FlyGame game;
  const ThrottleStick({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThrottleStickState();
}

class ThrottleStickState extends State<ThrottleStick> {
  double sliderValue = 5;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 50,
      bottom: 50,
      child: RotatedBox(
        quarterTurns: -1,
        child: Container(
          width: 200,
          height: 50,
          color: Colors.grey.withAlpha(100),
          child: Slider(
            min: 0,
            max: 10,
            value: sliderValue,
            onChanged: (value) {
              setState(() {
                widget.game.airplane.power.value = value;
                sliderValue = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
