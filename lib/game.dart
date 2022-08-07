import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flying_blind/characters/collectable.dart';

import 'dart:math';

import 'hud.dart';
import 'characters/airplane.dart';
import 'screens/options.dart';

class FlyGame extends FlameGame
    with
        HasCollisionDetection,
        HasDraggables,
        HasTappables,
        WidgetsBindingObserver {
  // fields
  BuildContext context;
  late Hud hud;
  Airplane airplane;
  double navballMovement = 0;
  int navballMovementMulti = 190;

  // constructor
  FlyGame(this.context, this.airplane) {
    debugMode = true;

    // tell if game (while running) has been minimized or closed
    WidgetsBinding.instance.addObserver(this);

    // head up display
    hud = Hud(
      game: this,
      priority: 1,
      context: context,
      airplane: airplane,
    );
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(hud);
    add(Collectable(gameRef: this));
  }

  @override
  void update(double dt) async {
    super.update(dt);

    airplane.updateAngles(hud.joystick.relativeDelta);

    airplane.crosshair.angle = airplane.angles.value.x;
    // airplane.navball.angle = -airplane.angles.value.x;

    navballMovement = (airplane.angles.value.y * navballMovementMulti);
    airplane.navball.position.y = navballMovement + (hud.screenSize.height / 2);

    // print(
    //     "${airplane.angles.value.y * 180 / 3.14} ${airplane.angles.value.x * 180 / 3.14}");

    // new accels
    airplane.updateThrottle(5);
    airplane.updateInertia(dt);

    if (Random().nextInt(500) == 100) {
      print("COLLECTABLE ADDED");
      add(Collectable(gameRef: this));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state != AppLifecycleState.resumed && !paused) {
      pauseEngine();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Options(game: this),
        ),
      );
    }
  }
}
