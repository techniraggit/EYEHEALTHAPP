import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:project_new/dinogame/sprite.dart';

import 'constants.dart';
import 'game_object.dart';



List<Sprite> cacti = [
  Sprite()
    ..imagePath = "assets/cacti/cacti_group.png"
    ..imageWidth = 85
    ..imageHeight = 80,
  Sprite()
    ..imagePath = "assets/cacti/cacti_large_1.png"
    ..imageWidth = 50
    ..imageHeight = 110,
  Sprite()
    ..imagePath = "assets/cacti/cacti_large_2.png"
    ..imageWidth = 78
    ..imageHeight = 80,
  Sprite()
    ..imagePath = "assets/cacti/cacti_small_1.png"
    ..imageWidth = 34
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "assets/cacti/cacti_small_2.png"
    ..imageWidth = 68
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "assets/cacti/cacti_small_3.png"
    ..imageWidth = 107
    ..imageHeight = 70,
];

class Cactus extends GameObject {
  final Sprite sprite;
  final Offset worldLocation;

  Cactus({required this.worldLocation}) : sprite = cacti[Random().nextInt(cacti.length)];

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio,
      screenSize.height / 1.75 - sprite.imageHeight,
      sprite.imageWidth.toDouble(),
      sprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(sprite.imagePath);
  }
}