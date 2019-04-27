import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:money_taker/game_logic.dart';

import 'moneytaker.dart';

const healthBarRadius = Radius.circular(8);
final healthBarPaint = Paint()..color = Color(0xff14932e);
final emptyHealthBarPaint = Paint()..color = Color(0xff383c42);

const healthBarSize = 200;

const TextConfig characterHp = TextConfig(
    fontSize: 24.0, fontFamily: 'Awesome Font', color: Color(0xff000000));

class CharacterComponent extends Component {
  Character character;
  SpriteComponent _sprite;

  double x, _y, charX, charY;

  double get width => game.screenSize.width * 0.25;

  MoneyTaker game;

  CharacterComponent(this.character, sprite, this.x, this._y, this.game) {
    this._sprite =
        SpriteComponent.fromSprite(width, game.screenSize.height * 0.8, sprite);
    charX = x;
  }

  @override
  void render(Canvas c) {
    characterHealthBar(c);

    _sprite.x = charX;
    _sprite.y = 60;
    _sprite.render(c);
  }

  void characterHealthBar(Canvas c) {
    c.drawRRect(RRect.fromLTRBR(x, _y, x + character.hpPercentage * healthBarSize, _y + 30, healthBarRadius),
        healthBarPaint);
    c.drawRRect(RRect.fromLTRBR(x, _y, x + healthBarSize, _y + 30, healthBarRadius),
        healthBarPaint);

    characterHp.render(c, "${character.curHp}/${character.maxHp}",
        Position(x + 50, _y));
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}
