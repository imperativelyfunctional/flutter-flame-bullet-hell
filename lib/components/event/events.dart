import 'package:event/event.dart';

enum BulletActionEnum {
  actionOne,
  actionTwo,
}

class BossAction extends EventArgs {
  BulletActionEnum bulletActionEnum;

  BossAction(this.bulletActionEnum);
}
