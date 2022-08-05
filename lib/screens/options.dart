import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import '../config.dart';
import 'menu.dart';

class Options extends StatelessWidget {
  final FlameGame? game;
  const Options({Key? key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: BabaText(
                "Settings",
                style: const TextStyle(
                  fontSize: 50.0,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Color.fromARGB(199, 255, 255, 255),
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            game != null
                ? Button(
                    onPressed: () {
                      // resume game
                      if (game!.paused) {
                        game!.resumeEngine();
                      }
                      // exit settings
                      Navigator.of(context).pop();
                    },
                    child: BabaText("Resume"),
                  )
                : Button(
                    onPressed: () {
                      // exit settings
                      Navigator.of(context).pop();
                    },
                    child: BabaText("Back"),
                  ),
            Button(
              onPressed: () {
                //navigation to options button
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const MainMenu(),
                  ),
                  (route) => route.isFirst,
                );
              },
              child: BabaText("Quit"),
            ),
          ],
        ),
      ),
    );
  }
}
