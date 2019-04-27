import 'dart:async';

import 'dart:math';

final Random Rng = Random();

class GameLogic {
  static Player player;
  static List<Enemy> enemies;

  static Level currentLevel;

  static attack(Character attacker, Character attackee) {
    attackee.loseHp(attacker.attack(0));
  }

  static void computeAI(Enemy enemy) {
    print("Enemy ${enemy.hashCode} attacked player");
    player.loseHp(enemy.attack(0));
  }

  static Future<void> enemiesTurn() async {
    for (final enemy in enemies) {
      computeAI(enemy);
    }
    await Future.delayed(const Duration(seconds: 1));
  }
}


class Level {
  int id;
}


class Character {
  int curHp = 100,
      maxHp = 100;

  bool get isAlive => curHp > 0;
  bool get isDead => !isAlive;


  int _damage = 10;
  int speed; // TODO

  GoldCurrency gold;

  Character(this.curHp, this.maxHp, this._damage, this.gold);

  loseHp(int amountLost) {
    curHp -= amountLost;
    if (curHp < 0) {
      curHp = 0;
    }
  }

  attack(int goldUsed) {
    // Normal attack between 75 and 125% of damage.
    // Can use up to 100 gold to ensure a 0.25 additional bonus.
    if (goldUsed > gold.amount) {
      goldUsed = gold.amount;
    }

    gold.lose(goldUsed);

    int attackDamage = ((0.75 + Rng.nextDouble() * 0.5 +
        goldUsed / 100 * 0.25) * _damage).round();
    print("attacking for $attackDamage");

    return attackDamage;
  }


  // TODO *********************
  upgradeDamage() {

  }

  upgradeHealth() {

  }

  upgradeSpeed() {

  }
}

class Enemy extends Character {
  Enemy(int curHp, int maxHp, int damage, GoldCurrency gold) : super(curHp, maxHp, damage, gold);
}


class Player extends Character {
  Player(int curHp, int maxHp, int damage, GoldCurrency gold) : super(curHp, maxHp, damage, gold);

}

class Currency {
  int amount;
  static double value;

  Currency(this.amount);

  lose(int lost) {
    this.amount -= lost;
  }
}

class GoldCurrency extends Currency {
  static double value = 1;

  GoldCurrency(int amount) : super(amount);
}

class RedCurrency extends Currency {
  static double value = 2;

  RedCurrency(int amount) : super(amount);
}

class GreenCurrency extends Currency {
  static double value = 2;

  GreenCurrency(int amount) : super(amount);
}

class PurpleCurrency extends Currency {
  static double value = 2;

  PurpleCurrency(int amount) : super(amount);
}


