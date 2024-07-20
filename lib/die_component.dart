import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:auriferous/auriferous_game.dart';
import 'package:auriferous/dice_pool_component.dart';
import 'package:auriferous/enums.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class DieComponent extends PositionComponent {
  late AuriferousGame game;
  late DicePoolComponent dicePool;
  Map<int, Sprite> dieSprites = Map();
  late SpriteButtonComponent dieSpriteButtonComponent;
  int value = 1;
  bool isRolling = true;
  double rollSpeed = Random().nextDouble() * 2 + 4;

  DieComponent(
      {required this.value,
      required Vector2 position,
      required this.game,
      required this.dicePool}) {
    this.position = position;
  }

  @override
  FutureOr<void> onLoad() async {
    // for (int i = 1; i < 6; i++) {
    //   dieSprites[i] = await Sprite.load('dice-six-faces-$i.png');
    // }

    final sprite = await Sprite.load('dice-six-faces-$value.png');

    dieSpriteButtonComponent =
        // SpriteComponent(sprite: dieSprites[value], size: Vector2.all(50));
        SpriteButtonComponent(
            button: sprite,
            buttonDown: sprite,
            onPressed: () => onPressedDie(),
            size: Vector2.all(50),
            position: Vector2(25, 25),
            anchor: Anchor.center);
    add(dieSpriteButtonComponent);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isRolling) {
      dieSpriteButtonComponent.angle += angle + dt * rollSpeed;

      // 6.283 = 2 * pi = one rotation
      if (dieSpriteButtonComponent.angle > 6.283) {
        isRolling = false;
        dieSpriteButtonComponent.angle = 0;
      }
    }

    super.update(dt);
  }

  onPressedDie() {
    print('pressed on die $value');
    switch (game.turnState) {
      case TurnState.powerDynamite:
        dicePool.reroll(this);
        break;
      default:
    }
  }
}
