import 'dart:async';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:money_taker/game_logic.dart';
import 'package:money_taker/game_over.dart';

class CombatPage extends Component {
  bool initialized = false;

  Sprite playerSprite = Sprite('player.png');
  Sprite enemySprite = Sprite('enemy.png');

  SpriteComponent playerComponent;

  SpriteComponent enemyComponent;

  Player player = Player(100, 100, 10, GoldCurrency(10));
  Enemy enemy = Enemy(50, 50, 5, GoldCurrency(30));

  bool _isPlayerTurn = true;

  Timer turnTimer;
  static const TurnDuration = 3.0; // s
  static const TurnTick = 16; // ms
  static const TurnTickDuration =
  const Duration(milliseconds: TurnTick); // for 60 fps
  static double turnTimeout = TurnDuration;


  Size screenSize;

  void resize(Size size) {
    screenSize = size;

    playerComponent = SpriteComponent.fromSprite(
        size.width * 0.3, size.height * 0.8, playerSprite);
    enemyComponent = SpriteComponent.fromSprite(
        size.width * 0.3, size.height * 0.8, enemySprite);

    playerComponent.x = 50;
    playerComponent.y = 20;

    enemyComponent.x = size.width - enemyComponent.width - playerComponent.x * 2;
    enemyComponent.y = 0;
  }

  @override
  void render(Canvas c) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Colors.black12;
    c.drawRect(bgRect, bgPaint);

    playerComponent.render(c);
    enemyComponent.render(c);
  }

  @override
  void update(double t) {
    if (!initialized) {
      initState();
      initialized = true;
    }
    if (player.isAlive && enemy.isAlive) {
      turnTimeout -= t;
      if (turnTimeout <= 0) {
        turnTimeout = 0;
        endPlayerTurn();
      }
    }
  }

  /******************** STATE ********************/
  void initState() {
    GameLogic.player = player;
    GameLogic.enemies = [enemy];

    playerTurn();
  }

  set isPlayerTurn(bool val) {
    _isPlayerTurn = val;
  }

  /********************** *************************/

  void handleTimer(Timer timer) async {
    print("time tick");
    if (turnTimeout <= 0.0) {
      await endPlayerTurn();
    } else {
      double newTimeout = turnTimeout -= TurnTick / 1000;
      if (newTimeout < 0) newTimeout = 0;
      turnTimeout = newTimeout;
    }
  }

  void playerTurn() {
    turnTimeout = 3.0;
    isPlayerTurn = true;
  }

  Future<void> endPlayerTurn() async {
    isPlayerTurn = false;
    if (player.isAlive) {
      if (enemy.isDead) {
        navigateGameWon();
      } else {
        await enemiesTurn();
      }
    } else {
      navigateGameOver();
    }
  }

  Future<void> enemiesTurn() async {
    await GameLogic.enemiesTurn();
    if (player.isDead) {
      navigateGameOver();
    }
    playerTurn();
  }

  void navigateGameWon() {
    print("win");
  }

  void navigateGameOver() {
    print("lose");
  }

  /******************** INPUT ************************/

  static void handleInput(dx, dy) {
    print(dx);
    print(dy);
  }

  playerAttack() {
    print("Player attacked enemy ${enemy.hashCode}");
    if (_isPlayerTurn) {
      GameLogic.attack(player, enemy);
      if (enemy.isDead) {
        navigateGameWon();
      }
      endPlayerTurn();
    }
  }

  /******************** ***** ************************/
}
