import 'package:carousel_slider/carousel_slider.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flying_blind/characters/airplane.dart';

import '../screens/options.dart';
import '../config.dart';
import 'play.dart';

class CharacterSelection extends StatefulWidget {
  CharacterSelection({Key? key}) : super(key: key);

  final List<String> characters = ["Small Plane", "Med Plane", "Big Plane"];
  final List<Airplane> airplanes = [
    // small
    Airplane(
      mass: 5000,
      size: Vector3(10, 5, 2),
      position: Vector3(0, 0, 5000),
    ),
    // med
    Airplane(
      mass: 10000,
      size: Vector3(50, 10, 3),
      position: Vector3(0, 0, 5000),
    ),
    // big
    Airplane(
      mass: 50000,
      size: Vector3(100, 20, 5),
      position: Vector3(0, 0, 5000),
    ),
  ];

  @override
  State<CharacterSelection> createState() => CharacterSelectionState();
}

class CharacterSelectionState extends State<CharacterSelection> {
  late Airplane airplane = widget.airplanes[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: BabaText("Character Selection"),
          ),
          CarouselSlider.builder(
            itemCount: 3,
            options: CarouselOptions(
              height: 200,
              aspectRatio: 2,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                airplane = widget.airplanes[index];
              },
            ),
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                color: const Color.fromARGB(30, 30, 30, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Image.asset(
                    //   'assets/images/atlas/${widget.characters[index]}_idle.gif',
                    //   scale: 1 / 3,
                    // ),
                    Text("${widget.characters[index]} IMAGE HERE"),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("mass: ${widget.airplanes[index].mass} kg"),
                        Text("length: ${widget.airplanes[index].size.x} m"),
                        Text("width: ${widget.airplanes[index].size.y} m"),
                        Text("height: ${widget.airplanes[index].size.z} m"),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Button(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GamePlay(
                      airplane: airplane,
                    ),
                  ),
                );
              },
              child: BabaText("Play"),
            ),
            Button(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Options(),
                  ),
                );
              },
              child: BabaText("Options"),
            ),
          ]),
        ]),
      ),
    );
  }
}
