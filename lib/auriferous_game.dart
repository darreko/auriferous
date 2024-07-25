import 'dart:async';
import 'dart:ui';

import 'package:auriferous/player_board.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class AuriferousGame extends FlameGame {
  @override
  bool debugMode = false;

  int mineGoldRemaining = 50;
  late List<PlayerBoard> playerBoards;

  @override
  FutureOr<void> onLoad() {
    FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
    var viewportSize = view.physicalSize / view.devicePixelRatio;
    var viewportWidth = viewportSize.width;
    var viewportHeight = viewportSize.height;

    // var boardSize = Vector2(viewportWidth, viewportHeight * .8);
    // var guiSize = Vector2(viewportWidth, viewportHeight * .2);

    var playerBoardSize = Vector2(viewportWidth, viewportHeight);

    // TODO: load player boards
    playerBoards = [
      PlayerBoard(name: "Player 1", startingGold: 0, playArea: playerBoardSize),
      // PlayerBoard(name: "Player 2", startingGold: 1, playArea: playerBoardSize),
    ];

    playerBoards[0].position = Vector2.all(0);
    // playerBoards[1].position = Vector2(viewportWidth / 2, 0);

    for (var playerBoard in playerBoards) {
      add(playerBoard);
    }

    return super.onLoad();
  }
}
