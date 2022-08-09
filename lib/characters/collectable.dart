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

    // min=150, max=500 : screen 'Z' axis randomizer
    double randomDistancer =
        gameRef.airplane.s.value.x + Random().nextInt(350) + 150;
    // min=-500, max=500 : screen X-Y axis randomizers
    // double randomYPositioner =
    //     gameRef.hud.screenSize.width / 2 + Random().nextInt(1000) - 500;
    // double randomZPositioner =
    //     gameRef.hud.screenSize.height / 2 + Random().nextInt(1000) - 500;
    double randomYPositioner =
        gameRef.airplane.s.value.y + Random().nextInt(1000) - 500;
    double randomZPositioner =
        gameRef.airplane.s.value.y + Random().nextInt(1000) - 500;

    // random real 3D position
    realPosition = Vector3(
      randomDistancer,
      randomYPositioner,
      randomZPositioner,
    );

    // random screen position
    position = Vector2(realPosition.y, realPosition.z);
  }

  realPosToScreen() {
    // pitch(y), yaw(z), roll(x)
    double navballPosChanged = 0;
    if (gameRef.airplane.angles.value.y <= 1.56 &&
        gameRef.airplane.angles.value.y >= -1.56) {
      navballPosChanged = gameRef.navballMovementMulti *
          (gameRef.hud.joystick.relativeDelta.y / gameRef.airplane.size.length);
    }

    // calc translation
    Vector2 tempPosition = Vector2(
      realPosition.y + -sin(gameRef.airplane.angles.value.x),
      realPosition.z + sin(gameRef.airplane.angles.value.y) + navballPosChanged,
    );
    realPosition.y = tempPosition.x;
    realPosition.z = tempPosition.y;

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
        // print("score : ${gameRef.score}");
      }
      // print("passed collectable");
      gameRef.remove(this);
    }
  }
}
