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

    double distanceTo = 500 + Random().nextDouble() * 200 - 100;
    double yRealDistance = gameRef.airplane.s.value.y +
        (Random().nextDouble() * 2 * gameRef.airplane.s.value.y / 2) -
        gameRef.airplane.s.value.y / 2;
    double zRealDistance = gameRef.airplane.s.value.z +
        (Random().nextDouble() * 2 * gameRef.airplane.s.value.z / 2) -
        gameRef.airplane.s.value.z / 2;
    // realPosition = Vector3(distanceTo, yRealDistance, zRealDistance);
    realPosition = Vector3(gameRef.airplane.s.value.x + 75, 0, 0);
    position = Vector2(
      gameRef.hud.screenSize.width / 2,
      gameRef.hud.screenSize.height / 2,
    );
  }

  realPosToScreen() {
    // // calc translation
    // Vector2 tempPosition = Vector2(
    //   (realPosition.y - gameRef.airplane.s.value.y) +
    //       gameRef.hud.screenSize.width / 2,
    //   (gameRef.airplane.s.value.z - realPosition.z) +
    //       gameRef.hud.screenSize.height / 2,
    // );
    // print(tempPosition);

    // pitch(y), yaw(z), roll(x)
    double navballPosChanged = 0;
    if (gameRef.airplane.angles.value.y <= 1.56 &&
        gameRef.airplane.angles.value.y >= -1.56) {
      navballPosChanged = gameRef.navballMovementMulti *
          (gameRef.hud.joystick.relativeDelta.y / gameRef.airplane.size.length);
      print(gameRef.airplane.angles.value.y);
    }
    // print(navballPosChanged);

    // calc translation
    Vector2 tempPosition = Vector2(
      position.x + -sin(gameRef.airplane.angles.value.x),
      position.y + sin(gameRef.airplane.angles.value.y) + navballPosChanged,
    );
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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    double minY = gameRef.airplane.s.value.y * 0.9;
    double maxY = gameRef.airplane.s.value.y * 1.1;

    double minZ = gameRef.airplane.s.value.z * 0.9;
    double maxZ = gameRef.airplane.s.value.z * 1.1;

    if (realPosition.x - gameRef.airplane.s.value.x < 50) {
      if (realPosition.y > minY && realPosition.y < maxY) {
        if (realPosition.z > minZ && realPosition.z < maxZ) {
          gameRef.remove(this);
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // real position to screen/display position
    realPosToScreen();

    // resize sprite to simulate depth
    size = defaultSize / (realPosition.x - gameRef.airplane.s.value.x).abs();

    // airplane has passed collectable
    if (gameRef.airplane.s.value.x > realPosition.x) {
      gameRef.remove(this);
    }
  }
}
