import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:auriferous/dice_pool_component.dart';
import 'package:auriferous/die_component.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class AuriferousGame extends FlameGame {
  late SpriteComponent board;
  late SpriteComponent dwarf;
  late TextComponent goldCountText;
  // late TextComponent dicePoolText;
  late DicePoolComponent dicePool;
  late SpriteButtonComponent rollButton;

  @override
  bool debugMode = false;

  // List<int> dicePool = List.empty();
  List<int> mineCartDice = List.empty(growable: true);
  int mineCartGold = 0;
  int mineGoldRemaining = 50;

  @override
  FutureOr<void> onLoad() async {
    try {
      // First get the FlutterView.
      FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
      var viewportSize = view.physicalSize / view.devicePixelRatio;
      var viewportWidth = viewportSize.width;
      var viewportHeight = viewportSize.height;

      var boardSize = Vector2(viewportWidth, viewportHeight * .8);
      var guiSize = Vector2(viewportWidth, viewportHeight * .2);

      board = SpriteComponent(
        position: Vector2(0, viewportHeight * .2),
        size: boardSize,
        //anchor: Anchor.topCenter,
        sprite: await Sprite.load('playerboard.png'),
      );
      add(board);

      goldCountText = TextComponent(
        text: 'Gold: 0',
        position: Vector2(0, 0),
        size: Vector2(guiSize.x / 10, guiSize.y),
      );
      add(goldCountText);

      // dicePoolText = TextComponent(
      //   text: 'Dice:',
      //   position: Vector2(guiSize.x / 5, 0),
      //   size: Vector2(guiSize.x / 2.5, guiSize.y),
      // );
      // add(dicePoolText);

      dicePool = DicePoolComponent(
        position: Vector2(guiSize.x / 10, 0),
        size: Vector2(guiSize.x / 8, guiSize.y),
      );
      add(dicePool);

      rollButton = SpriteButtonComponent(
        button: await loadSprite('roll_button.png'),
        buttonDown: await loadSprite('roll_button_pressed.png'),
        // children: [TextComponent(text: 'Roll')],
        onPressed: () => roll(),
        position: Vector2((guiSize.x / 10) * 9, 0),
        size: Vector2(guiSize.x / 10, guiSize.y),
      );
      add(rollButton);

      dwarf = SpriteComponent(
        position: Vector2(10, 20),
        size: Vector2.all(128),
        sprite: await Sprite.load('dorf2.png'),
      );

      // add(dwarf);
    } catch (ex) {
      print('an error: $ex');
    }
    return super.onLoad();
  }

  void roll() {
    final r = Random();
    final rolledValues = List.generate(5, (x) => r.nextInt(6) + 1);
    rolledValues.sort();
    dicePool.clear();
    dicePool.addDice(rolledValues);
  }
}
