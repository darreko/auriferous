import 'dart:math';

import 'package:auriferous/auriferous_game.dart';
import 'package:auriferous/die_component.dart';
import 'package:auriferous/enums.dart';
import 'package:flame/components.dart';

class DicePoolComponent extends PositionComponent {
  List<DieComponent> dice = <DieComponent>[];
  late AuriferousGame game;

  DicePoolComponent(
      {required Vector2 position, required Vector2 size, required this.game}) {
    this.position = position;
  }

  void addDiceByValue(List<int> dice) {
    for (int i = 0; i < dice.length; i++) {
      final die = DieComponent(
          value: dice[i],
          position: Vector2((i * 60) % 600, (i / 10).floor() * 60),
          game: game,
          dicePool: this);
      this.dice.add(die);
      add(die);
    }
  }

  void clear() {
    removeAll(dice);
    dice.clear();
  }

  @override
  void update(double dt) {
    if (game.turnState == TurnState.rolling &&
        !dice.any((die) => die.isRolling)) {
      game.setState(TurnState.choosePower);
    }

    super.update(dt);
  }

  void reroll(DieComponent die) {
    game.usedDynamites++;
    if (game.turnState == TurnState.powerDynamite &&
        game.usedDynamites >= game.numDynamites) {
      game.setState(TurnState.choosePower);
    } else {
      game.setState(TurnState.powerDynamite);
    }

    dice.remove(die);
    remove(die);

    final newDie = DieComponent(
        value: Random().nextInt(6) + 1,
        position: die.position,
        game: game,
        dicePool: this);
    dice.add(newDie);
    add(newDie);
  }
}
