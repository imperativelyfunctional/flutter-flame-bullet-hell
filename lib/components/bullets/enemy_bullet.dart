import 'dart:async' as async;
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:rpg_flame/components/bullets/mixins/bullets.dart';
import 'package:rpg_flame/components/player.dart';

class EnemyBullet extends SpriteComponent
    with CollisionCallbacks, BulletsMixin, HasGameRef {
  final double maxSpeed;
  Vector2 target;
  late Vector2 source;
  final Player player;
  bool homing;
  final int timeForHomingSeconds;

  EnemyBullet(this.player, this.target, this.maxSpeed,
      {this.homing = false, this.timeForHomingSeconds = 3})
      : super(size: Vector2(8, 12)) {
    damage = 1;
    add(RectangleHitbox());
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    source = Vector2(x, y);
    var tiles = await Flame.images.load('tiles_packed.png');
    sprite =
        Sprite(tiles, srcSize: Vector2(8, 12), srcPosition: Vector2(4, 18));
    if (homing) {
      async.Timer.periodic(Duration(seconds: timeForHomingSeconds), (timer) {
        homing = false;
        add(ColorEffect(Colors.deepOrange.withOpacity(0.4), const Offset(0.5, 0.5),
            EffectController(duration: 1)));
        timer.cancel();
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (homing) {
      angle = atan2(player.y - y, player.x - x) + pi / 2;
      moveAlongLine(source, player.position, maxSpeed * dt);
      target = player.position;
    } else {
      moveWithAngle(angle - pi / 2, maxSpeed * dt * 3);
    }
    if (offScreen(gameRef)) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      removeFromParent();
    }
  }
}
