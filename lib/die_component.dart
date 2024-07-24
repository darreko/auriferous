import 'dart:async';
import 'dart:math';

import 'package:auriferous/auriferous_game.dart';
import 'package:auriferous/dice_pool_component.dart';
import 'package:auriferous/enums.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class DieComponent extends PositionComponent {
  late AuriferousGame game;
  late DicePoolComponent dicePool;
  Map<int, Sprite> dieSprites = {};
  late SpriteButtonComponent dieSpriteButtonComponent;
  late SpriteButtonComponent bumpUpSpriteButtonComponent =
      SpriteButtonComponent();
  late SpriteButtonComponent bumpDownSpriteButtonComponent =
      SpriteButtonComponent();
  int _value = 1;
  int get value => _value;
  bool _isRolling = true;
  bool get isRolling => _isRolling;
  set isRolling(bool r) {
    _isRolling = r;
    dieSpriteButtonComponent.angle = 0;
  }

  double rollSpeed = Random().nextDouble() * 2 + 4;

  DieComponent(
      {required value,
      required Vector2 position,
      required this.game,
      required this.dicePool,
      bool isRolling = true}) {
    _value = value;
    this.position = position;
    _isRolling = isRolling;
  }

  @override
  FutureOr<void> onLoad() async {
    for (int i = 1; i <= 6; i++) {
      dieSprites[i] = await Sprite.load('dice-six-faces-$i.png');
    }
    final upSprite = await Sprite.load('plain-arrow-up.png');
    final downSprite = await Sprite.load('plain-arrow-down.png');

    dieSpriteButtonComponent = SpriteButtonComponent(
        button: dieSprites[_value],
        buttonDown: dieSprites[_value],
        onPressed: () => onPressedDie(),
        size: Vector2.all(50),
        position: Vector2(25, 25),
        anchor: Anchor.center);
    tryAdd(dieSpriteButtonComponent);

    bumpUpSpriteButtonComponent = SpriteButtonComponent(
        button: upSprite,
        buttonDown: upSprite,
        onPressed: () => onPressedBump(up: true),
        size: Vector2.all(20),
        position: Vector2(15, 0));

    bumpDownSpriteButtonComponent = SpriteButtonComponent(
        button: downSprite,
        buttonDown: downSprite,
        onPressed: () => onPressedBump(up: false),
        size: Vector2.all(20),
        position: Vector2(15, 40));

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

  showBumpButtons(bool show) {
    if (show) {
      if (value < 6) {
        tryAdd(bumpUpSpriteButtonComponent);
      }
      if (value > 1) {
        tryAdd(bumpDownSpriteButtonComponent);
      }
    } else {
      tryRemove(bumpUpSpriteButtonComponent);
      tryRemove(bumpDownSpriteButtonComponent);
    }
  }

  setValue(int value, bool rolling) {
    _value = value;
    isRolling = rolling;
    showBumpButtons(game.turnState == TurnState.powerPickaxe);

    tryRemove(dieSpriteButtonComponent);
    dieSpriteButtonComponent = SpriteButtonComponent(
        button: dieSprites[value],
        buttonDown: dieSprites[value],
        onPressed: () => onPressedDie(),
        size: Vector2.all(50),
        position: Vector2(25, 25),
        anchor: Anchor.center);
    tryAdd(dieSpriteButtonComponent);
  }

  onPressedDie() {
    print('pressed on die $value');
    switch (game.turnState) {
      case TurnState.powerDynamite:
        dicePool.reroll(this);
        break;
      case TurnState.powerMineCart:
        game.saveDieInMineCart(value);
        dicePool.removeDie(this);
        break;
      default:
    }
  }

  onPressedBump({required bool up}) {
    print('bumped the $value ${up ? 'up' : 'down'}');

    if ((up && value < 6) || !up && value > 1) {
      dicePool.bumpDie(this, up);
    }
  }
}
