import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'dart:math';

import '../game.dart';

class Collectable extends SpriteComponent with CollisionCallbacks {
  Vector2 defaultSize = Vector2(50, 50);
  late Vector3 realPosition;
  FlyGame gameRef;

  Collectable({
    required this.gameRef,
  }) {
    priority = 1;
    anchor = Anchor.center;

    double randSpawnMulti =
        (gameRef.hud.screenSize.width > gameRef.hud.screenSize.height)
            ? gameRef.hud.screenSize.height / 2
            : gameRef.hud.screenSize.width / 2;

    position = Vector2(
      gameRef.hud.screenSize.width / 2 + Random().nextDouble() * 100 - 50,
      gameRef.hud.screenSize.height / 2 + Random().nextDouble() * 100 - 50,
    );

    double distanceTo =
        gameRef.airplane.s.value.x + Random().nextDouble() * 500 - 250;
    double yRealDistance = gameRef.airplane.s.value.y +
        (Random().nextDouble() * 2 * gameRef.airplane.s.value.y / 2) -
        gameRef.airplane.s.value.y / 2;
    double zRealDistance = gameRef.airplane.s.value.z +
        (Random().nextDouble() * 2 * gameRef.airplane.s.value.z / 2) -
        gameRef.airplane.s.value.z / 2;
    realPosition = Vector3(distanceTo, yRealDistance, zRealDistance);
    realPosition.y = position.x;
    realPosition.z = position.y;
  }

  realPosToScreen() {
    // pitch(y), yaw(z), roll(x)
    double navballPosChanged = 0;
    if (gameRef.airplane.angles.value.y <= 1.56 &&
        gameRef.airplane.angles.value.y >= -1.56) {
      navballPosChanged = gameRef.navballMovementMulti *
          (gameRef.hud.joystick.relativeDelta.y / gameRef.airplane.size.length);
      // print(gameRef.airplane.angles.value.y);
    }
    // print(navballPosChanged);

    // calc translation
    Vector2 tempPosition = Vector2(
      realPosition.y + -sin(gameRef.airplane.angles.value.x),
      realPosition.z + sin(gameRef.airplane.angles.value.y) + navballPosChanged,
    );
    realPosition.y = tempPosition.x;
    realPosition.z = tempPosition.y;
    // print(tempPosition);

    // check max/min screen x
    if (tempPosition.x < 0) {
      tempPosition.x = 0;
    } else if (tempPosition.x > gameRef.hud.screenSize.width) {
      tempPosition.x = gameRef.hud.screenSize.width;
    }
    // check max/min screen y
    if (tempPosition.y < 0) {
      tempPosition.y = 0;
    } else if (tempPosition.y > gameRef.hud.screenSize.height) {
      tempPosition.y = gameRef.hud.screenSize.height;
    }

    // update sprite position
    position = tempPosition;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load("circle.png");
  }

  @override
  void update(double dt) {
    super.update(dt);

    // real position to screen/display position
    realPosToScreen();

    // resize sprite to simulate depth
    double distanceToAirplane =
        (realPosition - gameRef.airplane.s.value).length;
    // size = defaultSize / distanceToAirplane;
    size = defaultSize / (realPosition.x - gameRef.airplane.s.value.x);

    // airplane has passed collectable
    if (gameRef.airplane.s.value.x > realPosition.x) {
      if (realPosition.z > gameRef.hud.screenSize.height * 0.9 / 2 &&
          realPosition.z < gameRef.hud.screenSize.height * 1.1 / 2 &&
          realPosition.y > gameRef.hud.screenSize.width * 0.9 / 2 &&
          realPosition.y < gameRef.hud.screenSize.width * 1.1 / 2) {
        gameRef.score.value++;
        print("score : ${gameRef.score}");
      }
      print("passed collectable");
      gameRef.remove(this);
    }
  }
}
