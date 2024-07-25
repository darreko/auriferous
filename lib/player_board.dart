import 'dart:async';
import 'dart:math';

import 'package:auriferous/constants.dart';
import 'package:auriferous/dice_pool_component.dart';
import 'package:auriferous/enums.dart';
import 'package:auriferous/player.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class PlayerBoard extends PositionComponent {
  late Player player;

  late SpriteComponent boardSprite;
  late SpriteComponent dwarfSprite;
  late TextComponent goldCountText;
  late TextComponent helpfulText;

  late DicePoolComponent dicePool;
  late SpriteButtonComponent rollButton;

  late SpriteButtonComponent useDynamiteButton;
  late SpriteButtonComponent useMineCartButton;
  late SpriteButtonComponent useShivButton;
  late SpriteButtonComponent usePickaxeButton;

  static late SpriteButtonComponent upgradeDynamiteButton;
  static late SpriteButtonComponent upgradeMineCartButton;
  static late SpriteButtonComponent upgradeShivButton;
  static late SpriteButtonComponent upgradePickaxeButton;
  static late SpriteButtonComponent upgradeLunchboxButton;

  late Map<int, SpriteButtonComponent> upgradeButtonByDieValue;

  late SpriteButtonComponent doneButton;
  late SpriteButtonComponent strikeGoldButton;

  PlayerBoard(
      {required String name, required int startingGold, required playArea}) {
    player = Player(name, startingGold);
    size = playArea;
  }

  @override
  FutureOr<void> onLoad() async {
    try {
      // First get the FlutterView.
      // FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
      // var viewportSize = view.physicalSize / view.devicePixelRatio;
      // var viewportWidth = viewportSize.width;
      // var viewportHeight = viewportSize.height;

      var boardSize = Vector2(size.x, size.y * .8);
      var guiSize = Vector2(size.x, size.y * .2);

      boardSprite = SpriteComponent(
        position: Vector2(0, size.y * .2),
        size: boardSize,
        sprite: await Sprite.load('playerboard.png'),
      );
      add(boardSprite);

      goldCountText = TextComponent(
        text: 'Gold: ${player.goldCount}',
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
        playerBoard: this,
      );
      add(dicePool);

      rollButton = SpriteButtonComponent(
        button: await Sprite.load('roll_button.png'),
        buttonDown: await Sprite.load('roll_button_pressed.png'),
        onPressed: () => roll(),
        position: Vector2((guiSize.x / 10) * 9, 0),
        size: Vector2(guiSize.x / 10, guiSize.y),
      );

      strikeGoldButton = SpriteButtonComponent(
        button: await Sprite.load('strike_gold.png'),
        buttonDown: await Sprite.load('strike_gold.png'),
        onPressed: () => strikeGold(),
        position: Vector2((guiSize.x / 10) * 9, 0),
        size: Vector2(guiSize.x / 10, guiSize.y),
      );

      dwarfSprite = SpriteComponent(
        position: Vector2(10, 20),
        size: Vector2.all(128),
        sprite: await Sprite.load('dorf2.png'),
      );

      // add(dwarf);

      useDynamiteButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.dynamite),
        size: Vector2(170, 70),
        position: Vector2(20, 500),
      );

      upgradeDynamiteButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.dynamite),
        size: Vector2(170, 70),
        position: Vector2(20, 200),
      );

      useMineCartButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.minecart),
        size: Vector2(170, 70),
        position: Vector2(190, 500),
      );

      upgradeMineCartButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.minecart),
        size: Vector2(170, 70),
        position: Vector2(190, 200),
      );

      useShivButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.shiv),
        size: Vector2(170, 70),
        position: Vector2(360, 500),
      );

      upgradeShivButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.shiv),
        size: Vector2(170, 70),
        position: Vector2(360, 200),
      );

      usePickaxeButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => powerPressed(Powers.pickaxe),
        size: Vector2(170, 70),
        position: Vector2(530, 500),
      );

      upgradePickaxeButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.pickaxe),
        size: Vector2(170, 70),
        position: Vector2(530, 200),
      );

      upgradeLunchboxButton = SpriteButtonComponent(
        button: await Sprite.load('highlight_rect.png'),
        buttonDown: await Sprite.load('highlight_rect.png'),
        onPressed: () => upgradePowerPressed(Powers.lunchbox),
        size: Vector2(170, 70),
        position: Vector2(700, 200),
      );

      upgradeButtonByDieValue = {
        1: upgradeDynamiteButton,
        2: upgradeMineCartButton,
        3: upgradeShivButton,
        4: upgradePickaxeButton,
        5: upgradeLunchboxButton
      };

      doneButton = SpriteButtonComponent(
        button: await Sprite.load('done_button.png'),
        buttonDown: await Sprite.load('done_button.png'),
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
        List.generate(5 + player.numLunchboxes, (x) => r.nextInt(6) + 1);
    rolledValues.sort();
    dicePool.clear();
    dicePool.addDiceByValue(rolledValues, player.mineCartDice);
    player.mineCartDice.clear();
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
        player.numPowerByDieValue[1] =
            player.availableUpgradeDepthsByDieValue[1]!;
        break;
      case Powers.minecart:
        player.numPowerByDieValue[2] =
            player.availableUpgradeDepthsByDieValue[2]!;
        break;
      case Powers.shiv:
        player.numPowerByDieValue[3] =
            player.availableUpgradeDepthsByDieValue[3]!;
        break;
      case Powers.pickaxe:
        player.numPowerByDieValue[4] =
            player.availableUpgradeDepthsByDieValue[4]!;
        break;
      case Powers.lunchbox:
        player.numPowerByDieValue[5] =
            player.availableUpgradeDepthsByDieValue[5]!;
        break;
      default:
    }
    setState(TurnState.turnFinished);
  }

  void setState(TurnState state) {
    player.turnState = state;
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
        for (var x in dicePool.dice) {
          x.showBumpButtons(false);
        }

        if (!addAvailablePowerButtons()) {
          setState(TurnState.sendMinerOrCollectGold);
          break;
        }
        tryAdd(doneButton);

        helpfulText.text =
            'Choose one of your powers to use at the bottom of the screen!';
        break;
      case TurnState.powerDynamite:
        removePowerButtons();
        tryAdd(doneButton);

        helpfulText.text = 'Click on a die you'
            'd like to reroll! You have ${player.numDynamites - player.usedDynamites} remaining!';

      case TurnState.powerMineCart:
        removePowerButtons();
        tryAdd(doneButton);

        helpfulText.text = 'Click on a die you'
            'd like to save for a future turn! You have ${player.numMineCarts - player.usedMineCarts} remaining!';
      case TurnState.powerShiv:
        removePowerButtons();
        tryAdd(doneButton);

        helpfulText.text =
            'Not implemented! You have $player.{numShivs - player.usedShivs} remaining!';
      case TurnState.powerPickaxe:
        removePowerButtons();
        tryAdd(doneButton);

        for (var x in dicePool.dice) {
          x.showBumpButtons(true);
        }

        helpfulText.text = 'Click on a die you'
            'd like to bump! You have ${player.numPickaxes - player.usedPickaxes} remaining!';
        break;
      case TurnState.sendMinerOrCollectGold:
        removePowerButtons();
        tryAdd(doneButton);
        tryAdd(strikeGoldButton);
        positionAndShowAvailableUpgradeButtons();
        helpfulText.text =
            'Choose a mine to send your miner to, or strike gold!';
        break;
      case TurnState.turnFinished:
        tryRemove(doneButton);
        tryRemove(strikeGoldButton);
        removeUpgradeButtons();
        resetPowers();
        dicePool.clear();
        helpfulText.text = 'Please wait for your next turn';
        goldCountText.text = 'Gold: ${player.goldCount}';
        Future.delayed(
            const Duration(seconds: 1), () => setState(TurnState.beforeRoll));
        break;
      default:
    }
  }

  bool addAvailablePowerButtons() {
    int numPowersAvailable = 0;

    if (player.numDynamites > player.usedDynamites) {
      tryAdd(useDynamiteButton);
      numPowersAvailable++;
    }
    if (player.numMineCarts > player.usedMineCarts) {
      tryAdd(useMineCartButton);
      numPowersAvailable++;
    }
    if (player.numShivs > player.usedShivs) {
      tryAdd(useShivButton);
      numPowersAvailable++;
    }
    if (player.numPickaxes > player.usedPickaxes) {
      tryAdd(usePickaxeButton);
      numPowersAvailable++;
    }

    return numPowersAvailable > 0;
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
    player.usedDynamites = 0;
    player.usedMineCarts = 0;
    player.usedShivs = 0;
    player.usedPickaxes = 0;
  }

  donePressed() {
    switch (player.turnState) {
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

    // For each die value, check and see if we should show an upgrade
    for (var i = 1; i <= 5; i++) {
      player.availableUpgradeDepthsByDieValue[i] =
          diceRequiredForLevelByDieValue[i]!
                  .keys
                  .where((key) =>
                      diceRequiredForLevelByDieValue[i]![key]! <=
                      (dicePerValue[i] as int))
                  .lastOrNull ??
              0;

      if (player.availableUpgradeDepthsByDieValue[i]! >
          player.numPowerByDieValue[i]!) {
        upgradeButtonByDieValue[i]!.position = Vector2(
            upgradeButtonByDieValue[i]!.position.x,
            setUpgradeButtonHeight(
                player.availableUpgradeDepthsByDieValue[i]!));
        tryAdd(upgradeButtonByDieValue[i]!);
      }
    }
  }

  double setUpgradeButtonHeight(int highestPossibleTier) {
    return 200 + (highestPossibleTier - 1) * 60;
  }

  void saveDieInMineCart(int value) {
    print('saved a $value in the mine cart!');
    player.mineCartDice.add(value);
    player.usedMineCarts++;
    if (player.turnState == TurnState.powerMineCart &&
        player.usedMineCarts >= player.numMineCarts) {
      setState(TurnState.choosePower);
    } else {
      setState(TurnState.powerMineCart);
    }
  }

  strikeGold() {
    final dicePerValue = dicePool.getNumberOfDicePerValue();
    final numSixes = dicePerValue[6]!;
    final int add;

    if (numSixes == 0) {
      add = 0;
    } else if (numSixes <= goldPerDie.length) {
      add = goldPerDie[numSixes]!;
      player.goldCount += add;
    } else {
      add =
          goldPerDie[goldPerDie.length]! + ((numSixes - goldPerDie.length) * 3);
      player.goldCount += add;
    }
    print('striking $add gold from $numSixes sixes');
    setState(TurnState.turnFinished);
  }
}
