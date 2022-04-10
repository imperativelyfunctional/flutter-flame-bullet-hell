import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:rpg_flame/components/boss.dart';
import 'package:rpg_flame/components/bullets/mixins/bullets.dart';
import 'package:rpg_flame/components/tank.dart';

class PlaneBullet extends SpriteComponent
    with HasGameRef, CollisionCallbacks, BulletsMixin {
  double maxSpeed = 1000;
  late double initialAngle;
  late double targetAngle;

  PlaneBullet(this.initialAngle, this.targetAngle)
      : super(size: Vector2(12, 14), anchor: Anchor.center) {
    angle = initialAngle;
    add(RectangleHitbox());
    damage = 2;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    var tiles = await Flame.images.load('tiles_packed.png');
    sprite =
        Sprite(tiles, srcSize: Vector2(12, 14), srcPosition: Vector2(18, 1));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (offScreen(gameRef)) {
      removeFromParent();
    }
    moveWithAngle(targetAngle, maxSpeed * dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Tank || other is Boss) {
      removeFromParent();
    }
  }
}
