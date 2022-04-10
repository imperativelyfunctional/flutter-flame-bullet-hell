import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:rpg_flame/main.dart';

mixin BulletsMixin on PositionComponent {
  late int damage;

  moveAlongLine(Vector2 source, Vector2 target, double speed) {
    var v = target.y - source.y;
    var h = target.x - source.x;
    var distance = sqrt(pow(v, 2) + pow(h, 2));
    position.add(Vector2(h / distance, v / distance) * speed);
  }

  moveWithAngle(num radians, double speed) {
    position.add(Vector2(cos(radians), sin(radians)) * speed);
  }

  bool offScreen(FlameGame game) {
    var position = game.camera.position;

    return absolutePosition.x < position.x ||
        absolutePosition.x > position.x + viewPortWidth ||
        absolutePosition.y < 0 ||
        absolutePosition.y > viewPortHeight;
  }
}
