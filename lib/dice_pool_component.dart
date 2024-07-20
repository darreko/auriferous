import 'package:auriferous/die_component.dart';
import 'package:flame/components.dart';

class DicePoolComponent extends PositionComponent {
  List<DieComponent> dice = List.empty();

  DicePoolComponent({required Vector2 position, required Vector2 size}) {
    this.position = position;
  }

  void addDice(List<int> dice) {
    print('dice pool adding dice: $dice');
    for (int i = 0; i < dice.length; i++) {
      var die = dice[i];
      add(DieComponent(die, Vector2((i * 60) % 600, (i / 10).floor() * 60)));
    }
  }

  void clear() {
    // removes all dice from the pool
    removeAll(dice);
  }
}
