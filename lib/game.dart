import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'hud.dart';
import 'screens/play.dart';
import 'screens/options.dart';
import 'characters/airplane.dart';
import 'characters/collectable.dart';

class FlyGame extends FlameGame
    with
        HasCollisionDetection,
        HasDraggables,
        HasTappables,
        WidgetsBindingObserver {
  // fields
  BuildContext context;
  Airplane airplane;
  late ThrottleStick throttleStick;
  late Hud hud;

  ValueNotifier<int> score = ValueNotifier<int>(0);
  double navballMovement = 0;
  final int navballMovementMulti = 190;

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

    // throttle controller
    throttleStick = ThrottleStick(game: this);
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

    // update pitch, roll, yaw
    airplane.updateAngles(hud.joystick.relativeDelta);

    // update avionics
    airplane.crosshair.angle = airplane.angles.value.x;
    // airplane.navball.angle = -airplane.angles.value.x;
    navballMovement = (airplane.angles.value.y * navballMovementMulti);
    airplane.navball.position.y = navballMovement + (hud.screenSize.height / 2);

    // new accels
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
