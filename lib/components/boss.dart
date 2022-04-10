import 'dart:async' as async;
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:rpg_flame/components/bullets/animated_enemy_bullet.dart';
import 'package:rpg_flame/components/bullets/mixins/bullets.dart';
import 'package:rpg_flame/components/bullets/mixins/weapon.dart';
import 'package:rpg_flame/components/event/events.dart';
import 'package:rpg_flame/components/player.dart';
import 'package:rpg_flame/main.dart';

import 'bullets/plane_bullet.dart';

class Boss extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks, BulletsMixin, Weapon {
  double maxSpeed = 100.0;
  final Player player;
  final AudioPool explosion;
  final AudioPool zap;
  bool visible = false;
  final Vector2 textureSize;
  final String image;
  bool paused = true;
  async.Timer? timer;

  Boss(this.player, this.explosion, this.zap,
      {required this.image, required this.textureSize})
      : super(size: Vector2(28, 30)) {
    add(RectangleHitbox());
    anchor = Anchor.center;
    angle = -pi / 2;
    health = 500;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    animation = await gameRef.loadSpriteAnimation(
      image,
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0, 0),
        amount: 5,
        textureSize: textureSize,
        stepTime: 0.2,
        loop: true,
      ),
    );

    event.subscribe((args) {
      var bulletActionEnum = args!.bulletActionEnum;
      if (timer != null) {
        timer!.cancel();
        timers.remove(timer);
      }
      timer = _shoot(bulletActionEnum);
    });
  }

  _shoot(BulletActionEnum bulletAction) {
    async.Timer(const Duration(seconds: 4), () {
      var timer =
          async.Timer.periodic(const Duration(milliseconds: 200), (timer) {
        switch (bulletAction) {
          case BulletActionEnum.actionOne:
            {
              _bulletOne();
              break;
            }
          case BulletActionEnum.actionTwo:
            {
              _bulletTwo();
              break;
            }
        }
      });
      this.timer = timer;
      timers.add(timer);
    });
  }

  void _bulletOne() {
    var bullet = AnimatedEnemyBullet(
      player,
      Vector2(player.x - width, player.y),
      100,
      homing: true,
      timeForHomingSeconds: 3,
      amount: 2,
      image: 'bullet1.png',
      textureSize: Vector2(12, 12),
      size: Vector2(12, 12),
    )
      ..position = Vector2(x - width / 2, y)
      ..angle = atan2(player.y - y, player.x - x) + pi / 2;
    parent!.add(bullet);
  }

  void _bulletTwo() {
    var bullet = AnimatedEnemyBullet(
      player,
      Vector2(player.x - width, player.y),
      100,
      homing: true,
      timeForHomingSeconds: 3,
      amount: 2,
      image: 'bullet2.png',
      textureSize: Vector2(6, 14),
      size: Vector2(6, 14),
    )
      ..position = Vector2(x - width / 2, y)
      ..angle = atan2(player.y - y, player.x - x) + pi / 2;
    parent!.add(bullet);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!paused) {
      angle = atan2(player.y - y, player.x - x) + pi / 2;
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
  }

  @override
  void onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollision(intersectionPoints, other);
    if (other is PlaneBullet) {
      zap.start(volume: 0.3);
      health -= other.damage;
      if (health <= 0) {
        removeFromParent();
        explosion.start(volume: 0.5);
        for (var element in timers) {
          element.cancel();
        }
      }
    }
  }
}
