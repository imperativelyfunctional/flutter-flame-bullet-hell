import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:rpg_flame/components/bullets/enemy_bullet.dart';

class Shield extends CircleComponent with CollisionCallbacks {
  Shield({required double radius, required Paint paint})
      : super(radius: radius, paint: paint) {
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is EnemyBullet) {
      other.removeFromParent();
    }
  }
}
