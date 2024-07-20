import 'package:auriferous/die_component.dart';
import 'package:flame/components.dart';

class DicePoolComponent extends PositionComponent {
  List<DieComponent> dice = <DieComponent>[];

  DicePoolComponent({required Vector2 position, required Vector2 size}) {
    this.position = position;
  }

  void addDice(List<int> dice) {
    for (int i = 0; i < dice.length; i++) {
      final die =
          DieComponent(dice[i], Vector2((i * 60) % 600, (i / 10).floor() * 60));
      this.dice.add(die);
      add(die);
    }
  }

  void clear() {
    removeAll(dice);
    dice.clear();
  }
}
