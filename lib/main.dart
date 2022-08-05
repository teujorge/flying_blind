import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/extensions.dart';

import 'game.dart';
import 'screens/menu.dart';

//  Load the game widgets
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  Flame.device.fullScreen();
  runApp(
    MaterialApp(
      // theme: ThemeData(fontFamily: 'BABA'),
      // themeMode: ThemeMode.dark,
      // darkTheme: ThemeData.dark(),
      home: const MainMenu(),
    ),
  );
}
