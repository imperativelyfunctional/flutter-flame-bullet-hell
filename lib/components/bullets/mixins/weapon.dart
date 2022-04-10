import 'dart:async' as async;

import 'package:flame/components.dart';

mixin Weapon on PositionComponent {
  late int health;

  List<async.Timer> timers = [];
}
