import 'dart:async' as async;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../plane_bullet.dart';

extension BulletsExtension on PositionComponent {
  async.Timer shoot(
      {Vector2? scale,
      Color? color,
      double? initialAngle,
      double? targetAngle}) {
    return async.Timer.periodic(const Duration(milliseconds: 200), (timer) {
      var bullet = PlaneBullet((initialAngle == null) ? angle : initialAngle,
          (targetAngle == null) ? 0 : targetAngle)
        ..position = position
        ..scale = (scale == null) ? Vector2(1, 1) : scale
        ..add(ColorEffect((color == null) ? Colors.deepPurple : color,
            const Offset(1, 1), EffectController(duration: 1, infinite: true)));
      parent!.add(bullet);
    });
  }

  async.Timer shoot2({
    Vector2? scale,
    Color? color,
  }) {
    return async.Timer.periodic(const Duration(milliseconds: 100), (timer) {
      var bullet = PlaneBullet(angle, angle - pi / 2)
        ..position = position
        ..scale = (scale == null) ? Vector2(1, 1) : scale;
      if (color != null) {
        bullet.add(ColorEffect(Colors.deepPurple.withOpacity(0.4),
            const Offset(0.5, 0.5), EffectController(duration: 1)));
      }
      parent!.add(bullet);
    });
  }
}
