import 'dart:async';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:money_taker/game_logic.dart';

import 'character_component.dart';

const TextConfig timerText = TextConfig(
    fontSize: 32.0, fontFamily: 'Awesome Font', color: Color(0xffff0000));

const TextConfig goldText = TextConfig(
    fontSize: 32.0, fontFamily: 'Awesome Font', color: Color(0xfff4d142));

class MoneyTaker extends BaseGame {
  Size screenSize;

  final Sprite playerSprite = Sprite('player.png');
  CharacterComponent playerComponent;
  static final Position playerStartPosition = Position(20, 20);

  final Sprite enemySprite = Sprite('enemy.png');
  CharacterComponent enemyComponent;

  final SpriteComponent attackIcon =
      SpriteComponent.fromSprite(50, 50, Sprite('attackIcon.png'));
  bool displayAttackIcon = false;

  Player player = Player(100, 100, 10, GoldCurrency(100));
  Enemy enemy = Enemy(50, 50, 5, GoldCurrency(30));

  bool _isPlayerTurn = true;

  Timer turnTimer;
  static const TurnDuration = 3.0; // s
  static const TurnTick = 16; // ms
  static const TurnTickDuration =
      const Duration(milliseconds: TurnTick); // for 60 fps
  static double turnTimeout = TurnDuration;

  bool isCombatFinished = false;

  double startDrag;

  GestureRecognizer horizontalDragGestureHandler;

  bool isPlayerAttacking = false;

  MoneyTaker() {
    initialize();
  }

  void initialize() async {
    horizontalDragGestureHandler = HorizontalDragGestureRecognizer()
      ..onStart = handleHorizontalDragStart
      ..onUpdate = handleHorizontalDragUpdate
      ..onEnd = handleHorizontalDragEnd;

    this.screenSize = await Flame.util.initialDimensions();
    resize(screenSize);
    playerComponent = CharacterComponent(player, playerSprite,
        playerStartPosition.x, playerStartPosition.y, this);
    enemyComponent = CharacterComponent(enemy, enemySprite,
        screenSize.width * 0.7, playerStartPosition.y, this);

    GameLogic.player = player;
    GameLogic.enemy = enemy;

    playerTurn();
  }

  void render(Canvas c) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff2c3d59);
    c.drawRect(bgRect, bgPaint);

    c.save();
    playerComponent.render(c);

    if (displayAttackIcon) {
      attackIcon.render(c);
    }

    c.restore();
    enemyComponent.render(c);

    c.restore();
    goldText.render(c, player.gold.amount.toString(),
        Position(playerStartPosition.x, playerStartPosition.y + 50));
    timerText.render(c, getTimerText(),
        Position(playerStartPosition.x + playerComponent.width + 20, 0));
  }

  String getTimerText() {
    return _isPlayerTurn
        ? "ACT! QUICK! ${turnTimeout.toStringAsFixed(2)}s"
        : "ENEMY'S TURN!";
  }

  @override
  void update(double t) {
    if (isCombatFinished) {
    } else if (_isPlayerTurn) {
      turnTimeout -= t;
      if (turnTimeout <= 0) {
        print("Player failed to play!");
        turnTimeout = 0;
        endPlayerTurn();
      }
    }
  }

  /******************** STATE ********************/
  set isPlayerTurn(bool val) {
    _isPlayerTurn = val;
  }

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
    print("Player turn");
    turnTimeout = 3.0;
    isPlayerTurn = true;
  }

  playerAttack() {
    print("Player attacked enemy ${enemy.hashCode}");
    if (_isPlayerTurn && !isCombatFinished) {
      GameLogic.attack(player, enemy);
      if (enemy.isDead) {
        navigateGameWon();
      }
      endPlayerTurn();
    }
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
    isCombatFinished = true;
    isPlayerTurn = false;
    player.loot(enemy);
    enemy = GameLogic.nextEnemy(enemy);
    enemyComponent.character = enemy;
    isCombatFinished = false;
    playerTurn();
  }

  void navigateGameOver() {
    print("lose");
    isCombatFinished = true;
    isPlayerTurn = false;
  }

  /********************** *************************/

  /******************** INPUT ************************/

  static void handleTap(dx, dy) {
    print(dx);
    print(dy);
  }

  void handleHorizontalDragEnd(DragEndDetails details) {
    playerComponent.charX = playerStartPosition.x;
    if (isPlayerAttacking && _isPlayerTurn) {
      playerAttack();
    }
  }

  void handleHorizontalDragStart(DragStartDetails details) {
    if (_isPlayerTurn) {
      print("drag start");
      startDrag = details.globalPosition.dx;
    }
  }

  void handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isPlayerTurn) {
      final dragX = details.globalPosition.dx;
      final displacement = (dragX - startDrag);

      final double endPoint = enemyComponent.x - (playerComponent.width) - 20;
      playerComponent.charX = (playerStartPosition.x + displacement)
          .clamp(playerStartPosition.x, endPoint);

      if (displacement > (enemyComponent.x - playerComponent.x) / 2) {
        isPlayerAttacking = true;
      } else {
        isPlayerAttacking = false;
      }
    }
  }

/******************** ***** ************************/
}
