import 'package:flutter/material.dart';

class GameOver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("GAME OVER!")));
  }

}

class GameWon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("GAME WON!")));
  }

}