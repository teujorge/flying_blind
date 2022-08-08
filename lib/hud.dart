import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'game.dart';
import 'screens/options.dart';
import 'characters/airplane.dart';

class Hud extends Component {
// game and app
  late final BuildContext context;
  late final Airplane airplane;
  late Size screenSize;
  final FlyGame game;

  // movement and slected character
  late final JoystickComponent joystick;

  // 3 ability buttons locations (margins)
  final abilityMargin1 = const EdgeInsets.only(bottom: 125, right: 25);
  final abilityMargin2 = const EdgeInsets.only(bottom: 25, right: 125);
  final abilityMargin3 = const EdgeInsets.only(bottom: 75, right: 75);

  Hud({
    super.children,
    super.priority,
    required this.game,
    required this.context,
    required this.airplane,
  }) {
    positionType = PositionType.viewport;

    // controlls joystick
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 25,
        paint: BasicPalette.blue.withAlpha(200).paint(),
      ),
      background: CircleComponent(
        radius: 75,
        paint: BasicPalette.blue.withAlpha(100).paint(),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    // init size
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // draw night vision
    // draw navigation
    // draw altimeter
    // draw attitude

    canvas.drawCircle(
      const Offset(20, 20),
      20,
      Paint()
        ..color = airplane.v.value.z >= 0
            ? const Color.fromARGB(255, 10, 255, 10)
            : const Color.fromARGB(255, 255, 10, 10),
    );
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    // pitch ball
    airplane.navball
      ..size = Vector2(
        screenSize.width * 0.6,
        screenSize.height * 2,
      )
      ..position = Vector2(
        screenSize.width / 2,
        500,
      );
    airplane.navball.sprite = await Sprite.load("navball.png");
    add(airplane.navball);

    // roll crosshair
    airplane.crosshair
      ..size = Vector2(100, 100)
      ..position = Vector2(
        screenSize.width / 2,
        screenSize.height / 2,
      );
    airplane.crosshair.sprite = await Sprite.load("crosshair.png");
    add(airplane.crosshair);

    // acc
    final aTextComponent = TextComponent(
      text: 'Acc: ',
      position: Vector2(50, 50),
    );
    add(aTextComponent);
    airplane.a.addListener(() {
      aTextComponent.text =
          'Acc X: ${airplane.a.value.x.round()}\nAcc Y: ${airplane.a.value.y.round()}\nAcc Z: ${airplane.a.value.z.round()}';
    });

    // vel
    final vTextComponent = TextComponent(
      text: 'Vel: ',
      position: Vector2(50, 150),
    );
    add(vTextComponent);
    airplane.v.addListener(() {
      vTextComponent.text =
          'Vel X: ${airplane.v.value.x.round()}\nVel Y: ${airplane.v.value.y.round()}\nVel Z: ${airplane.v.value.z.round()}';
    });

    // pos
    final sTextComponent = TextComponent(
      text: 'Pos: ',
      position: Vector2(50, 250),
    );
    add(sTextComponent);
    airplane.s.addListener(() {
      sTextComponent.text =
          'Pos X: ${airplane.s.value.x.round()}\nPos Y: ${airplane.s.value.y.round()}\nPos Z: ${airplane.s.value.z.round()}';
    });

    // angles
    final angTextComponent = TextComponent(
      text: 'Angles: ',
      position: Vector2(200, 50),
    );
    add(angTextComponent);
    airplane.angles.addListener(() {
      angTextComponent.text =
          'Pitch: ${(airplane.angles.value.y * 180 / 3.14).round()}\nRoll: ${(airplane.angles.value.x * 180 / 3.14).round()}\nYaw: ${(airplane.angles.value.z * 180 / 3.14).round()}';
    });

    // score
    final scoreTextComponent = TextComponent(
      text: 'Angles: ',
      position: Vector2(200, 50),
    );
    add(scoreTextComponent);
    game.score.addListener(() {
      scoreTextComponent.text = 'Score: ${game.score.value}';
    });

    // joystick
    add(joystick);

    // settings
    add(
      PauseButton(
        margin: const EdgeInsets.only(top: 20, right: 20),
        context: context,
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    screenSize = MediaQuery.of(context).size;
  }
}

class HudButton extends HudMarginComponent with Tappable {
  final Paint outlinePaintColor = Paint()
    ..color = const Color.fromARGB(255, 0, 0, 0);
  final Paint disableBackground = Paint()
    ..color = const Color.fromARGB(150, 255, 5, 5);
  final Paint ableBackground = Paint()
    ..color = const Color.fromARGB(150, 80, 255, 5);
  Paint background = Paint()..color = const Color.fromARGB(150, 80, 255, 5);
  ui.Image? image;
  String? imagePath;

  HudButton({
    required EdgeInsets margin,
    this.imagePath,
  }) : super(
          margin: margin,
          size: Vector2.all(50),
        );

  Future<ui.Image> loadImage(Uint8List img) {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<ui.Image> initImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return loadImage(Uint8List.view(data.buffer));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (imagePath != null) {
      image = await initImage(imagePath!);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // background
    canvas.drawRect(size.toRect(), background);
    // image
    if (image != null) {
      canvas.drawImage(image!, const Offset(0, 0), background);
    }
    // outline
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, size.y),
      outlinePaintColor,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.y, 0),
      outlinePaintColor,
    );
    canvas.drawLine(
      Offset(0, size.y),
      Offset(size.y, size.y),
      outlinePaintColor,
    );
    canvas.drawLine(
      Offset(size.y, 0),
      Offset(size.y, size.y),
      outlinePaintColor,
    );
  }
}

class PauseButton extends HudButton {
  BuildContext context;
  final TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);

  PauseButton({required EdgeInsets margin, required this.context, image})
      : super(margin: margin, imagePath: image) {
    IconData icon = Icons.settings_rounded;
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(fontSize: 50.0, fontFamily: icon.fontFamily),
    );
    textPainter.layout();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    // enter settings
    gameRef.pauseEngine();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Options(game: gameRef),
      ),
    );

    return true;
  }
}
