import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'combat_page.dart';

void main() async {
  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.landscapeRight);
  MoneyTaker game = MoneyTaker();
  Flame.util.addGestureRecognizer(new TapGestureRecognizer()
    ..onTapDown = (TapDownDetails evt) => game.handleInput(evt.globalPosition.dx, evt.globalPosition.dy));
  runApp(game.widget);
}

class MoneyTaker extends BaseGame {
  MoneyTaker() {
    add(CombatPage());
  }

  handleInput() {

  }
}
