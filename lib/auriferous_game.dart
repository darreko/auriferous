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

  late SpriteButtonComponent useDynamiteButton;
  late SpriteButtonComponent useMineCartButton;
  late SpriteButtonComponent useShivButton;
  late SpriteButtonComponent usePickaxeButton;

  late SpriteButtonComponent upgradeDynamiteButton;
  late SpriteButtonComponent upgradeMineCartButton;
  late SpriteButtonComponent upgradeShivButton;
  late SpriteButtonComponent upgradePickaxeButton;
  late SpriteButtonComponent upgradeLunchboxButton;

  late SpriteButtonComponent doneButton;

  Map<int, int> diceRequiredForDynamiteLevel = {1: 1, 2: 2, 3: 3, 4: 4, 5: 5};
  Map<int, int> diceRequiredForMinecartLevel = {1: 1, 2: 2, 3: 3, 4: 4, 5: 5};
  Map<int, int> diceRequiredForShivLevel = {1: 1, 2: 3, 3: 5, 4: 7, 5: 10};
  Map<int, int> diceRequiredForPickaxeLevel = {1: 1, 2: 2, 3: 4, 4: 7, 5: 10};
  Map<int, int> diceRequiredForLunchboxLevel = {1: 2, 2: 4, 3: 6, 4: 8, 5: 10};

  int possibleUpgradeDepthDynamites = 0;
  int possibleUpgradeDepthMineCarts = 0;
  int possibleUpgradeDepthShivs = 0;
  int possibleUpgradeDepthPickaxes = 0;
  int possibleUpgradeDepthLunchboxes = 0;

  int numDynamites = 0;
  int numMineCarts = 0;
  int numShivs = 0;
  int numPickaxes = 0;
  int numLunchboxes = 0;

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

      useDynamiteButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.dynamite),
        size: Vector2(170, 70),
        position: Vector2(20, 500),
      );

      upgradeDynamiteButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.dynamite),
        size: Vector2(170, 70),
        position: Vector2(20, 200),
      );

      useMineCartButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.minecart),
        size: Vector2(170, 70),
        position: Vector2(190, 500),
      );

      upgradeMineCartButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.minecart),
        size: Vector2(170, 70),
        position: Vector2(190, 200),
      );

      useShivButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.shiv),
        size: Vector2(170, 70),
        position: Vector2(360, 500),
      );

      upgradeShivButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.shiv),
        size: Vector2(170, 70),
        position: Vector2(360, 200),
      );

      usePickaxeButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.pickaxe),
        size: Vector2(170, 70),
        position: Vector2(530, 500),
      );

      upgradePickaxeButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.pickaxe),
        size: Vector2(170, 70),
        position: Vector2(530, 200),
      );

      upgradeLunchboxButton = SpriteButtonComponent(
        button: await loadSprite('highlight_rect.png'),
        buttonDown: await loadSprite('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.lunchbox),
        size: Vector2(170, 70),
        position: Vector2(700, 200),
      );

      doneButton = SpriteButtonComponent(
        button: await loadSprite('done_button.png'),
        buttonDown: await loadSprite('done_button.png'),
        onPressed: () => donePressed(),
        size: Vector2(170, 70),
        position: Vector2(600, 60),
      );

      setState(TurnState.beforeRoll);
    } catch (ex) {
      print('an error: $ex');
    }
    return super.onLoad();
  }

  void roll() {
    setState(TurnState.rolling);
    final r = Random();
    final rolledValues =
        List.generate(5 + numLunchboxes, (x) => r.nextInt(6) + 1);
    rolledValues.sort();
    dicePool.clear();
    dicePool.addDiceByValue(rolledValues, mineCartDice);
    mineCartDice.clear();
  }

  void powerPressed(Powers power) {
    print('using $power');
    switch (power) {
      case Powers.dynamite:
        setState(TurnState.powerDynamite);
        break;
      case Powers.minecart:
        setState(TurnState.powerMineCart);
        break;
      case Powers.shiv:
        setState(TurnState.powerShiv);
        break;
      case Powers.pickaxe:
        setState(TurnState.powerPickaxe);
        break;
      default:
    }
  }

  upgradePowerPressed(Powers power) {
    print('upgraded $power');
    switch (power) {
      case Powers.dynamite:
        numDynamites = possibleUpgradeDepthDynamites;
        break;
      case Powers.minecart:
        numMineCarts = possibleUpgradeDepthMineCarts;
        break;
      case Powers.shiv:
        numShivs = possibleUpgradeDepthShivs;
        break;
      case Powers.pickaxe:
        numPickaxes = possibleUpgradeDepthPickaxes;
        break;
      case Powers.lunchbox:
        numLunchboxes = possibleUpgradeDepthLunchboxes;
        break;
      default:
    }
    setState(TurnState.turnFinished);
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

        helpfulText.text = 'Click on a die you'
            'd like to save for a future turn! You have ${numMineCarts - usedMineCarts} remaining!';
      case TurnState.powerShiv:
        removePowerButtons();
        tryAdd(doneButton);

        helpfulText.text =
            'Not implemented! You have ${numShivs - usedShivs} remaining!';
      case TurnState.powerPickaxe:
        removePowerButtons();
        tryAdd(doneButton);

        helpfulText.text = 'Click on a die you'
            'd like to bump! You have ${numPickaxes - usedPickaxes} remaining!';
        break;
      case TurnState.sendMinerOrCollectGold:
        removePowerButtons();
        tryAdd(doneButton);
        positionAndShowAvailableUpgradeButtons();
        helpfulText.text =
            'Choose a mine to send your miner to, or strike gold!';
        break;
      case TurnState.turnFinished:
        tryRemove(doneButton);
        removeUpgradeButtons();
        resetPowers();
        helpfulText.text = 'Please wait for your next turn';
        Future.delayed(
            const Duration(seconds: 1), () => setState(TurnState.beforeRoll));
        break;
      default:
    }
  }

  void addAvailablePowerButtons() {
    if (numDynamites > usedDynamites) {
      add(useDynamiteButton);
    }
    if (numMineCarts > usedMineCarts) {
      add(useMineCartButton);
    }
    if (numShivs > usedShivs) {
      add(useShivButton);
    }
    if (numPickaxes > usedPickaxes) {
      add(usePickaxeButton);
    }
  }

  void removePowerButtons() {
    tryRemove(useDynamiteButton);
    tryRemove(useMineCartButton);
    tryRemove(useShivButton);
    tryRemove(usePickaxeButton);
  }

  void removeUpgradeButtons() {
    tryRemove(upgradeDynamiteButton);
    tryRemove(upgradeMineCartButton);
    tryRemove(upgradeShivButton);
    tryRemove(upgradePickaxeButton);
    tryRemove(upgradeLunchboxButton);
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

  void resetPowers() {
    usedDynamites = 0;
    usedMineCarts = 0;
    usedShivs = 0;
    usedPickaxes = 0;
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

  positionAndShowAvailableUpgradeButtons() {
    final dicePerValue = dicePool.getNumberOfDicePerValue();

    // Dynamite
    possibleUpgradeDepthDynamites = diceRequiredForDynamiteLevel.keys
            .where((key) =>
                diceRequiredForDynamiteLevel[key]! <= (dicePerValue[1] as int))
            .lastOrNull ??
        0;

    if (possibleUpgradeDepthDynamites > numDynamites) {
      upgradeDynamiteButton.position = Vector2(upgradeDynamiteButton.position.x,
          setUpgradeButtonHeight(possibleUpgradeDepthDynamites));
      tryAdd(upgradeDynamiteButton);
    }

    // Minecart
    possibleUpgradeDepthMineCarts = diceRequiredForMinecartLevel.keys
            .where((key) =>
                diceRequiredForMinecartLevel[key]! <= (dicePerValue[2] as int))
            .lastOrNull ??
        0;

    if (possibleUpgradeDepthMineCarts > numMineCarts) {
      upgradeMineCartButton.position = Vector2(upgradeMineCartButton.position.x,
          setUpgradeButtonHeight(possibleUpgradeDepthMineCarts));
      tryAdd(upgradeMineCartButton);
    }

    // Shiv
    possibleUpgradeDepthShivs = diceRequiredForShivLevel.keys
            .where((key) =>
                diceRequiredForShivLevel[key]! <= (dicePerValue[3] as int))
            .lastOrNull ??
        0;

    if (possibleUpgradeDepthShivs > numShivs) {
      upgradeShivButton.position = Vector2(upgradeShivButton.position.x,
          setUpgradeButtonHeight(possibleUpgradeDepthShivs));
      tryAdd(upgradeShivButton);
    }

    // Pickaxe
    possibleUpgradeDepthPickaxes = diceRequiredForPickaxeLevel.keys
            .where((key) =>
                diceRequiredForPickaxeLevel[key]! <= (dicePerValue[4] as int))
            .lastOrNull ??
        0;

    if (possibleUpgradeDepthPickaxes > numPickaxes) {
      upgradePickaxeButton.position = Vector2(upgradePickaxeButton.position.x,
          setUpgradeButtonHeight(possibleUpgradeDepthPickaxes));
      tryAdd(upgradePickaxeButton);
    }

    // Lunchbox
    possibleUpgradeDepthLunchboxes = diceRequiredForLunchboxLevel.keys
            .where((key) =>
                diceRequiredForLunchboxLevel[key]! <= (dicePerValue[5] as int))
            .lastOrNull ??
        0;

    if (possibleUpgradeDepthLunchboxes > numLunchboxes) {
      upgradeLunchboxButton.position = Vector2(upgradeLunchboxButton.position.x,
          setUpgradeButtonHeight(possibleUpgradeDepthLunchboxes));
      tryAdd(upgradeLunchboxButton);
    }
  }

  double setUpgradeButtonHeight(int highestPossibleTier) {
    return 200 + (highestPossibleTier - 1) * 60;
  }

  void saveDieInMineCart(int value) {
    print('saved a $value in the mine cart!');
    mineCartDice.add(value);
    usedMineCarts++;
    if (turnState == TurnState.powerMineCart && usedDynamites >= numMineCarts) {
      setState(TurnState.choosePower);
    } else {
      setState(TurnState.powerMineCart);
    }
  }
}
