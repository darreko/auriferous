import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

class DieComponent extends PositionComponent {
  Map<int, Sprite> dieSprites = Map();
  late SpriteComponent dieSpriteComponent;
  int value = 1;
  bool isRolling = true;
  double rollSpeed = Random().nextDouble() * 2 + 4;

  DieComponent(this.value, Vector2 position) {
    this.position = position;
  }

  @override
  FutureOr<void> onLoad() async {
    // for (int i = 1; i < 6; i++) {
    //   dieSprites[i] = await Sprite.load('dice-six-faces-$i.png');
    // }

    final sprite = await Sprite.load('dice-six-faces-$value.png');

    dieSpriteComponent =
        // SpriteComponent(sprite: dieSprites[value], size: Vector2.all(50));
        SpriteComponent(
            sprite: sprite,
            size: Vector2.all(50),
            position: Vector2(25, 25),
            anchor: Anchor.center);
    add(dieSpriteComponent);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isRolling) {
      dieSpriteComponent.angle += angle + dt * rollSpeed;
      if (dieSpriteComponent.angle > 6.283) {
        isRolling = false;
        dieSpriteComponent.angle = 0;
      }
    }

    super.update(dt);
  }
}
