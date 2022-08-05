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

    // pitch(y), yaw(z), roll(x)

    airplane.angles.value += Vector3(
      hud.joystick.relativeDelta.x / airplane.size.length +
          (Random().nextDouble() * (20 / airplane.mass) - (10 / airplane.mass)),
      hud.joystick.relativeDelta.y / airplane.size.length +
          (Random().nextDouble() * (20 / airplane.mass) - (10 / airplane.mass)),
      0,
    );

    airplane.crosshair.angle = airplane.angles.value.x;
    // airplane.navball.angle = -airplane.angles.value.x;
    airplane.navball.position.y =
        (airplane.angles.value.y * 180) + (hud.screenSize.height / 2);

    // print(
    //     "${airplane.angles.value.y * 180 / 3.14} ${airplane.angles.value.x * 180 / 3.14}");

    // new accels
    airplane.updateInertia(dt);

    if (Random().nextInt(1000) == 1) {
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
