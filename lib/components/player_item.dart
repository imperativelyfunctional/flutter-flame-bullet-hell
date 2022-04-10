import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:rpg_flame/components/player.dart';

class PlayerItem extends SpriteComponent with CollisionCallbacks, HasGameRef {
  final Sprite item;
  final String type;

  PlayerItem(
    this.type, {
    required this.item,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
            sprite: item,
            paint: paint,
            position: position,
            size: size,
            scale: scale,
            angle: angle,
            anchor: anchor,
            priority: priority) {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      switch (type) {
        case 'shield':
          {
            other.addShield();
            break;
          }
        case 'power':
          {
            other.addPowerUps();
            break;
          }
      }
      removeFromParent();
    }
  }
}
