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
  Flame.images.load('player.png');
  Flame.images.load('enemy.png');
  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.landscapeRight);
  MoneyTaker game = MoneyTaker();
  runApp(game.widget);
  Flame.util.addGestureRecognizer(HorizontalDragGestureRecognizer()
      ..onEnd = game.handleHorizontalDrag);
}

class MoneyTaker extends BaseGame {
  CombatPage combatPage = CombatPage();
  MoneyTaker() {
    add((combatPage));
  }

  handleHorizontalDrag(DragEndDetails details) {
    print(details);
    combatPage.playerAttack();
  }
}
