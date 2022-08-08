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
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            ThrottleStick(game: game),
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
            max: 100,
            value: sliderValue,
            onChanged: (value) {
              setState(() {
                widget.game.airplane.power = value;
                sliderValue = value;
              });
              print(widget.game.airplane.power);
            },
          ),
        ),
      ),
    );
  }
}
