import 'dart:async' as async;
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flutter/material.dart';
import 'package:rpg_flame/components/boss.dart';
import 'package:rpg_flame/components/bullets/enemy_bullet.dart';
import 'package:rpg_flame/components/bullets/extensions/bullets.dart';
import 'package:rpg_flame/components/bullets/mixins/bullets.dart';
import 'package:rpg_flame/components/bullets/mixins/weapon.dart';
import 'package:rpg_flame/components/event/events.dart';
import 'package:rpg_flame/components/shield.dart';
import 'package:rpg_flame/components/tank.dart';

import '../main.dart';

class Player extends SpriteComponent
    with HasGameRef, CollisionCallbacks, Weapon, BulletsMixin {
  double maxSpeed = 150;

  final JoystickComponent joystick;
  final AudioPool pool;
  bool missionCleared = false;
  bool paused = false;
  final moveToController = EffectController(duration: 5);
  late AudioPool explosion;
  late AudioPool zap;
  Random random = Random(DateTime.now().microsecondsSinceEpoch);

  Player(this.joystick, this.pool) : super(size: Vector2(32, 24)) {
    add(RectangleHitbox());
    anchor = Anchor.center;
    angle = pi / 2;
    health = 2000;
  }

  addPowerUps() async {
    var planes = await Flame.images.load('ships_packed.png');

    var winger =
        Sprite(planes, srcSize: Vector2(24, 19), srcPosition: Vector2(4, 39));
    var wing1 = SpriteComponent(sprite: winger)
      ..anchor = Anchor.center
      ..position = Vector2(width / 2, height / 2)
      ..add(SpriteComponent(sprite: winger)
        ..position = Vector2(10, 30)
        ..scale = Vector2.all(0.4)
        ..add(ColorEffect(Colors.transparent, const Offset(0.6, 0.6),
            EffectController(duration: 1, infinite: true, reverseDuration: 1))))
      ..add(MoveAlongPathEffect(
          Path()
            ..addArc(Rect.fromCircle(center: const Offset(0, 0), radius: 40), 0,
                2 * pi),
          EffectController(duration: 4, infinite: true)));
    timers.add(wing1.shoot2(
        scale: Vector2(0.5, 0.5), color: Colors.blue.withAlpha(10)));

    add(wing1);

    var wing2 = SpriteComponent(sprite: winger)
      ..anchor = Anchor.center
      ..position = Vector2(width / 2, height / 2)
      ..add(SpriteComponent(sprite: winger)
        ..position = Vector2(10, 30)
        ..scale = Vector2.all(0.4)
        ..add(ColorEffect(Colors.transparent, const Offset(0.6, 0.6),
            EffectController(duration: 1, infinite: true, reverseDuration: 1))))
      ..add(MoveAlongPathEffect(
          Path()
            ..addArc(Rect.fromCircle(center: const Offset(0, 0), radius: 40),
                pi, -3 * pi),
          EffectController(
            duration: 4,
            infinite: true,
          )));
    timers.add(wing2.shoot2(
        scale: Vector2(0.5, 0.5), color: Colors.blue.withAlpha(10)));

    add(wing2);
  }

  addShield() {
    var halfWidth = width / 2;
    var halfHeight = height / 2;
    add(Shield(
        radius: 35,
        paint: Paint()..color = Colors.lightBlueAccent.withAlpha(100))
      ..position = Vector2(halfWidth, halfHeight));
    add(
      CircleComponent(
          position: Vector2(halfWidth, halfHeight),
          anchor: Anchor.center,
          radius: 20,
          paint: Paint()
            ..color = Colors.purple.withAlpha(30)
            ..strokeWidth = 6
            ..style = PaintingStyle.stroke),
    );
    add(
      CircleComponent(
          position: Vector2(halfWidth, halfHeight),
          anchor: Anchor.center,
          radius: 22,
          paint: Paint()
            ..color = Colors.orangeAccent.withAlpha(120)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke),
    );
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    var planes = await gameRef.images.load('ships_packed.png');
    var pool =
        await AudioPool.create('laser.mp3', minPlayers: 1, maxPlayers: 1);

    sprite =
        Sprite(planes, srcPosition: Vector2(0, 4), srcSize: Vector2(32, 24));
    position = gameRef.size / 2;

    explosion =
        await AudioPool.create('explosion.wav', minPlayers: 1, maxPlayers: 2);

    zap = await AudioPool.create('zap.mp3', minPlayers: 1, maxPlayers: 2);
    timers.add(shoot2(
      scale: Vector2(1, 1.5),
    ));
    add(SpriteComponent(sprite: sprite)
      ..position = Vector2(10, 30)
      ..scale = Vector2.all(0.4)
      ..add(ColorEffect(Colors.transparent, const Offset(0.6, 0.6),
          EffectController(duration: 1, infinite: true, reverseDuration: 1))));
  }

  @override
  void update(double dt) {
    if (!paused) {
      if (!joystick.delta.isZero()) {
        var vector2 = joystick.relativeDelta * maxSpeed * dt;
        var x = vector2.x;
        var y = vector2.y;
        if ((this.x + x) > worldWidth - width / 2) {
          vector2.x = 0;
        }
        if ((this.x + x - width / 2) < 0) {
          vector2.x = 0;
        }
        if (this.y + y - height / 2 < 0) {
          vector2.y = 0;
        }
        if (this.y + y + height / 2 > viewPortHeight) {
          vector2.y = 0;
        }
        position.add(vector2);
      }

      var cameraPosition = gameRef.camera.position;
      if (x - height / 2 < cameraPosition.x) {
        x = cameraPosition.x + height / 2;
      } else if (x + width / 2 > cameraPosition.x + viewPortWidth) {
        x = cameraPosition.x + viewPortWidth - width / 2;
      }

      if (!gameRef.children.any((element) => element is Tank)) {
        if (!missionCleared) {
          paused = true;
          (gameRef as IFRpgGame).missionCleared();
          missionCleared = true;
          gameRef.children.query<Boss>().forEach((element) {
            element.paused = false;
          });
          add(MoveEffect.to(
              Vector2(cameraPosition.x + 30, viewPortHeight / 2 - height / 2),
              moveToController));

          event.broadcast(BossAction(Random().nextBool()
              ? BulletActionEnum.actionOne
              : BulletActionEnum.actionTwo));

          async.Timer.periodic(const Duration(seconds: 10), (timer) {
            event.broadcast(BossAction(Random().nextBool()
                ? BulletActionEnum.actionOne
                : BulletActionEnum.actionTwo));
          });

          async.Timer.periodic(const Duration(seconds: 5), (timer) {
            var numberOfTanks = gameRef.children.query<Tank>().length;
            if (numberOfTanks < 10) {
              for (int i = 0; i < 10 - numberOfTanks; i++) {
                gameRef.add(Tank(this, explosion, zap)
                  ..position = Vector2(
                      cameraPosition.x +
                          random.nextInt(viewPortWidth.toInt() - 8).toDouble(),
                      random.nextInt(worldHeight.toInt() - 8) + 8)
                  ..size = Vector2(16, 16));
              }
            }
          });
        }
      }
    }

    if (moveToController.completed) {
      paused = false;
    }
  }

  @override
  void onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollision(intersectionPoints, other);
    if (other is EnemyBullet) {
      health -= other.damage;
      if (health <= 0) {
        pool.start(volume: 0.8);
        removeFromParent();
        for (var element in timers) {
          element.cancel();
        }
        (gameRef as IFRpgGame).gameOver();
      }
      add(ColorEffect(
          Colors.red.withAlpha(130),
          const Offset(0.1, 0.5),
          EffectController(
              duration: 0.5, infinite: false, reverseDuration: 0.5)));
    }
  }
}
