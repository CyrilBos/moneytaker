
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';

const TextConfig DamageText = TextConfig(
    fontSize: 18.0, fontFamily: 'Awesome Font', color: Color(0xffff0000));

final DamageCirclePaint = Paint()..color = Color(0xfff48942);

class TemporaryText extends Component {
  double x, y;
  double duration = 1;

  bool dispose = false;

  String text;

  TemporaryText(this.x, this.y, this.text);

  @override
  void render(Canvas c) {
    c.drawCircle(Offset(x,y), 24, DamageCirclePaint);
    DamageText.render(c, text, Position(x + 12, y + 12));
  }

  @override
  void update(double t) {
    duration -= t;
    if (duration <= 0) {
      dispose = true;
    }
  }

  @override
  bool destroy() {
    return dispose;
  }

}