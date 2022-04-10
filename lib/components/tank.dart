import 'dart:async' as async;
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:rpg_flame/components/bullets/mixins/bullets.dart';
import 'package:rpg_flame/components/bullets/mixins/weapon.dart';
import 'package:rpg_flame/components/bullets/plane_bullet.dart';
import 'package:rpg_flame/components/player.dart';

import 'bullets/enemy_bullet.dart';

class Tank extends SpriteComponent
    with HasGameRef, CollisionCallbacks, BulletsMixin, Weapon {
  double maxSpeed = 100.0;
  final Player player;
  late SpriteAnimation animation;
  final AudioPool explosion;
  final AudioPool zap;
  bool visible = false;

  Tank(this.player, this.explosion, this.zap)
      : super(size: Vector2(16, 15)) {
    add(RectangleHitbox());
    anchor = Anchor.center;
    health = 10;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    var tiles = await Flame.images.load('tiles_packed.png');
    sprite =
        Sprite(tiles, srcSize: Vector2(16, 15), srcPosition: Vector2(64, 33));

    animation = await gameRef.loadSpriteAnimation(
      'tiles_packed.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(64, 0),
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.4,
        loop: false,
      ),
    );

    timers.add(async.Timer.periodic(const Duration(milliseconds: 500), (timer) {
      gameRef.add(EnemyBullet(player, Vector2(player.x, player.y), 50,
          homing: true, timeForHomingSeconds: 2)
        ..position = Vector2(x, y)
        ..angle = atan2(player.y - y, player.x - x) + pi / 2);
    }));
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle = atan2(player.y - y, player.x - x) - pi / 2;
    if (offScreen(gameRef) && visible) {
      for (var element in timers) {
        element.cancel();
      }
      removeFromParent();
    }

    if (!offScreen(gameRef)) {
      visible = true;
    }
  }

  @override
  void onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollision(intersectionPoints, other);
    if (other is PlaneBullet) {
      zap.start(volume: 0.3);
      health -= other.damage;
      if (health <= 0) {
        final animationComponent = SpriteAnimationComponent(
          removeOnFinish: true,
          animation: animation,
          size: Vector2.all(16.0),
          anchor: Anchor.center,
          position: Vector2(x, y),
        );
        gameRef.add(animationComponent);
        removeFromParent();
        explosion.start(volume: 0.5);
        for (var element in timers) {
          element.cancel();
        }
      }
    }
  }
}
