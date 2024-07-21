import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:auriferous/dice_pool_component.dart';
import 'package:auriferous/enums.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class AuriferousGame extends FlameGame {
  late SpriteComponent board;
  late SpriteComponent dwarf;
  late TextComponent goldCountText;
  late TextComponent helpfulText;

  late DicePoolComponent dicePool;
  late SpriteButtonComponent rollButton;
  late TurnState turnState;

  late SpriteButtonComponent dynamiteButton;
  late SpriteButtonComponent mineCartButton;
  late SpriteButtonComponent shivButton;
  late SpriteButtonComponent pickAxeButton;

  late SpriteButtonComponent doneButton;

  int numDynamites = 3;
  int numMineCarts = 3;
  int numShivs = 0;
  int numPickaxes = 3;
  int numLunchboxes = 3;

  int usedDynamites = 0;
  int usedMineCarts = 0;
  int usedShivs = 0;
  int usedPickaxes = 0;
  int usedLunchboxes = 0;

  @override
  bool debugMode = false;

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

      helpfulText = TextComponent(
        text: 'Roll the dice with the button to the right! -->',
        position: Vector2(0, 60),
        size: Vector2(guiSize.x / 10, guiSize.y / 2),
      );
      add(helpfulText);

      dicePool = DicePoolComponent(
        position: Vector2(guiSize.x / 10, 0),
        size: Vector2(guiSize.x / 8, guiSize.y),
        game: this,
      );
      add(dicePool);

      rollButton = SpriteButtonComponent(
        button: await loadSprite('roll_button.png'),
        buttonDown: await loadSprite('roll_button_pressed.png'),
        onPressed: () => roll(),
        position: Vector2((guiSize.x / 10) * 9, 0),
        size: Vector2(guiSize.x / 10, guiSize.y),
      );
      // add(rollButton);

      dwarf = SpriteComponent(
        position: Vector2(10, 20),
        size: Vector2.all(128),
        sprite: await Sprite.load('dorf2.png'),
      );

      // add(dwarf);

      dynamiteButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.dynamite),
        size: Vector2(170, 70),
        position: Vector2(20, 500),
      );

      mineCartButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.minecart),
        size: Vector2(170, 70),
        position: Vector2(190, 500),
      );

      shivButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.shiv),
        size: Vector2(170, 70),
        position: Vector2(360, 500),
      );

      pickAxeButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.pickaxe),
        size: Vector2(170, 70),
        position: Vector2(530, 500),
      );

      doneButton = SpriteButtonComponent(
        button: await loadSprite('done_button.png'),
        buttonDown: await loadSprite('done_button.png'),
        onPressed: () => donePressed(),
        size: Vector2(170, 70),
        position: Vector2(600, 60),
      );
      //add(doneButton);

      setState(TurnState.beforeRoll);
    } catch (ex) {
      print('an error: $ex');
    }
    return super.onLoad();
  }

  void roll() {
    setState(TurnState.rolling);
    final r = Random();
    final rolledValues = List.generate(5, (x) => r.nextInt(6) + 1);
    rolledValues.sort();
    dicePool.clear();
    dicePool.addDiceByValue(rolledValues);
  }

  void powerPressed(Powers power) {
    print('using $power');
    switch (power) {
      case Powers.dynamite:
        setState(TurnState.powerDynamite);
        break;
      case Powers.minecart:
        setState(TurnState.powerDynamite);
        break;
      case Powers.shiv:
        setState(TurnState.powerDynamite);
        break;
      case Powers.pickaxe:
        setState(TurnState.powerDynamite);
        break;
      default:
    }
  }

  void setState(TurnState state) {
    turnState = state;
    print('state changed to $state');

    switch (state) {
      case TurnState.beforeRoll:
        tryAdd(rollButton);
        tryRemove(doneButton);
        helpfulText.text = 'Roll the dice with the button to the right! -->';
        break;
      case TurnState.rolling:
        tryRemove(rollButton);
        helpfulText.text = 'Look at them dice babay!';
        break;
      case TurnState.choosePower:
        addAvailablePowerButtons();
        tryAdd(doneButton);
        helpfulText.text =
            'Choose one of your powers to use at the bottom of the screen!';
        break;
      case TurnState.powerDynamite:
        removePowerButtons();
        tryAdd(doneButton);

        helpfulText.text = 'Click on a die you'
            'd like to reroll! You have ${numDynamites - usedDynamites} remaining!';

      case TurnState.powerMineCart:
        removePowerButtons();
        tryAdd(doneButton);
      case TurnState.powerShiv:
        removePowerButtons();
        tryAdd(doneButton);
      case TurnState.powerPickaxe:
        removePowerButtons();
        tryAdd(doneButton);
        break;
      case TurnState.sendMinerOrCollectGold:
        removePowerButtons();
        tryAdd(doneButton);
        helpfulText.text =
            'Choose a mine to send your miner to, or strike gold!';
        break;
      case TurnState.turnFinished:
        tryRemove(doneButton);
        helpfulText.text = 'Please wait for your next turn';
        Future.delayed(
            const Duration(seconds: 1), () => setState(TurnState.beforeRoll));
        break;
      default:
    }
  }

  void addAvailablePowerButtons() {
    if (numDynamites > usedDynamites) {
      add(dynamiteButton);
    }
    if (numMineCarts > usedMineCarts) {
      add(mineCartButton);
    }
    if (numShivs > usedShivs) {
      add(shivButton);
    }
    if (numPickaxes > usedPickaxes) {
      add(pickAxeButton);
    }
  }

  void removePowerButtons() {
    tryRemove(dynamiteButton);
    tryRemove(mineCartButton);
    tryRemove(shivButton);
    tryRemove(pickAxeButton);
  }

  void tryAdd(Component component) {
    if (!children.contains(component)) {
      add(component);
    }
  }

  void tryRemove(Component component) {
    if (children.contains(component)) {
      remove(component);
    }
  }

  donePressed() {
    switch (turnState) {
      case TurnState.powerDynamite:
      case TurnState.powerMineCart:
      case TurnState.powerShiv:
      case TurnState.powerPickaxe:
        setState(TurnState.choosePower);
        break;
      case TurnState.choosePower:
        setState(TurnState.sendMinerOrCollectGold);
        break;
      case TurnState.sendMinerOrCollectGold:
        setState(TurnState.turnFinished);
        break;
      default:
    }
  }
}
