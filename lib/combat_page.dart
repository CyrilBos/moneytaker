import 'dart:async';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:money_taker/game_logic.dart';
import 'package:money_taker/game_over.dart';

class CombatPage extends Component {
  Sprite playerSprite = Sprite('player.png');
  Sprite enemySprite = Sprite('enemy.png');

  SpriteComponent playerComponent;
  SpriteComponent enemyComponent;

  Player player = Player(100, 100, 10, GoldCurrency(10));
  List<Enemy> enemies = [Enemy(50, 50, 5, GoldCurrency(30))];

  bool _isPlayerTurn = true;

  Timer turnTimer;
  static const TurnDuration = 3.0; // s
  static const TurnTick = 16; // ms
  static const TurnTickDuration =
  const Duration(milliseconds: TurnTick); // for 60 fps
  static double turnTimeout = TurnDuration;


  Size screenSize;

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
    // TODO: implement update
  }

  void resize(Size size) {
    screenSize = size;
    playerComponent = SpriteComponent.fromSprite(
        size.width * 0.4, size.height * 0.8, playerSprite);
    enemyComponent = SpriteComponent.fromSprite(
        size.width * 0.4, size.height * 0.8, enemySprite);
  }

  /******************** STATE ********************/
  @override
  void initState() {
    GameLogic.player = player;
    GameLogic.enemies = enemies;

    playerTurn();
  }

  set isPlayerTurn(bool val) {
    setState(() {
      _isPlayerTurn = val;
    });
  }

  /********************** *************************/

  void startPlayerTurnTimer() {
    turnTimer = Timer.periodic(TurnTickDuration, handleTimer);
  }

  void handleTimer(Timer timer) async {
    print("time tick");
    if (turnTimeout <= 0.0) {
      await endPlayerTurn();
    } else {
      double newTimeout = turnTimeout -= TurnTick / 1000;
      if (newTimeout < 0) newTimeout = 0;
      setState(() => (turnTimeout = newTimeout));
    }
  }

  void playerTurn() {
    setState(() => turnTimeout = 3.0);
    startPlayerTurnTimer();
    isPlayerTurn = true;
  }

  Future<void> endPlayerTurn() async {
    turnTimer.cancel();
    isPlayerTurn = false;
    if (player.isAlive) {
      if (enemies.length == 0) {
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
    Navigator.push(MaterialPageRoute(builder: (context) => GameWon()));
  }

  void navigateGameOver() {
    Navigator.push(
        MaterialPageRoute(builder: (context) => GameOver()));
  }

  /******************** INPUT ************************/

  playerAttack(Enemy enemy, BuildContext context) {
    print("Player attacked enemy ${enemy.hashCode}");
    if (_isPlayerTurn) {
      GameLogic.attack(player, enemy);
      if (enemy.isDead) {
        enemies.remove(enemy);
      }
      endPlayerTurn();
    }
  }

  /******************** ***** ************************/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
        buildPlayerInfo(),
        buildTimer(),
        buildEnemies(context),
      ] // This trailing comma makes auto-formatting nicer for build methods.
          ),
    ));
  }

  Widget buildTimer() {
    if (!_isPlayerTurn) return Text("ENEMIES TURN!");

    return Text("${turnTimeout.toStringAsFixed(2)}S REMAINING TO PLAY!");
  }

  Widget buildPlayerInfo() {
    return Text("YOUR HEALTH: ${player.curHp} / ${player.maxHp}");
  }

  Widget buildEnemies(BuildContext context) {
    return Column(
      children: enemies.map((enemy) => buildEnemy(enemy)).toList(),
    );
  }

  Widget buildEnemy(Enemy enemy) {
    return Column(children: [
      Text("ENEMY HEALTH: ${enemies[0].curHp} / ${enemies[0].maxHp}"),
      FloatingActionButton(
        onPressed: () => playerAttack(enemies[0]),
        tooltip: 'Increment',
        child: Icon(Icons.thumb_down),
      )
    ]);
  }
}
