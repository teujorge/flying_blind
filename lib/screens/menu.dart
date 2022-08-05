import 'package:flutter/material.dart';

import '../config.dart';
import 'play.dart';
import 'selection.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  dispose() {
    _controller.dispose(); // you need this
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/images/background_castle.png"),
              //   fit: BoxFit.cover,
              // ),
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: BabaText(
                  "Flying Blind",
                  style: const TextStyle(
                    fontSize: 100.0,
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
              FadeTransition(
                opacity: _animation,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CharacterSelection(),
                      ),
                    );
                  },
                  child: BabaText(
                    "Press to start",
                    style: const TextStyle(fontSize: 70, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
