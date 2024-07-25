import 'dart:math';

import 'package:auriferous/die_component.dart';
import 'package:auriferous/enums.dart';
import 'package:auriferous/player_board.dart';
import 'package:flame/components.dart';

class DicePoolComponent extends PositionComponent {
  List<DieComponent> dice = <DieComponent>[];
  late PlayerBoard playerBoard;

  DicePoolComponent(
      {required Vector2 position,
      required Vector2 size,
      required this.playerBoard}) {
    this.position = position;
  }

  void addDiceByValue(List<int> rolledDice, List<int> mineCartDice) {
    for (int i = 0; i < rolledDice.length; i++) {
      final die = DieComponent(
          value: rolledDice[i],
          position: Vector2((i * 60) % 600, (i / 10).floor() * 60),
          playerBoard: playerBoard,
          dicePool: this);
      dice.add(die);
      add(die);
    }
    for (int i = 0; i < mineCartDice.length; i++) {
      final die = DieComponent(
          value: mineCartDice[i],
          position: Vector2(((i + rolledDice.length) * 60) % 600,
              ((i + rolledDice.length) / 10).floor() * 60),
          playerBoard: playerBoard,
          dicePool: this,
          isRolling: false);
      dice.add(die);
      add(die);
    }
  }

  void clear() {
    removeAll(dice);
    dice.clear();
  }

  @override
  void update(double dt) {
    if (playerBoard.player.turnState == TurnState.rolling &&
        !dice.any((die) => die.isRolling)) {
      playerBoard.setState(TurnState.choosePower);
    }

    super.update(dt);
  }

  void reroll(DieComponent die) {
    playerBoard.player.usedDynamites++;
    if (playerBoard.player.turnState == TurnState.powerDynamite &&
        playerBoard.player.usedDynamites >= playerBoard.player.numDynamites) {
      playerBoard.setState(TurnState.choosePower);
    } else {
      playerBoard.setState(TurnState.powerDynamite);
    }

    die.setValue(Random().nextInt(6) + 1, true);
  }

  Map<int, int> getNumberOfDicePerValue() {
    final Map<int, int> numberOfDicePerValue = {};
    for (int i = 1; i <= 6; i++) {
      numberOfDicePerValue[i] = dice.where((d) => d.value == i).length;

      print('You have ${numberOfDicePerValue[i]} $i s');
    }
    return numberOfDicePerValue;
  }

  void removeDie(DieComponent die) {
    dice.remove(die);
    remove(die);
  }

  void bumpDie(DieComponent die, bool up) {
    die.setValue(up ? die.value + 1 : die.value - 1, true);

    playerBoard.player.usedPickaxes++;
    if (playerBoard.player.turnState == TurnState.powerPickaxe &&
        playerBoard.player.usedPickaxes >= playerBoard.player.numPickaxes) {
      playerBoard.setState(TurnState.choosePower);
    } else {
      playerBoard.setState(TurnState.powerPickaxe);
    }
  }
}
