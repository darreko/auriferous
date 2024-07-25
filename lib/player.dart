import 'package:auriferous/enums.dart';

class Player {
  String name;
  late int goldCount;

  late TurnState turnState;

  Map<int, int> availableUpgradeDepthsByDieValue = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0
  };

  int get possibleUpgradeDepthDynamites => availableUpgradeDepthsByDieValue[1]!;
  int get possibleUpgradeDepthMineCarts => availableUpgradeDepthsByDieValue[2]!;
  int get possibleUpgradeDepthShivs => availableUpgradeDepthsByDieValue[3]!;
  int get possibleUpgradeDepthPickaxes => availableUpgradeDepthsByDieValue[4]!;
  int get possibleUpgradeDepthLunchboxes =>
      availableUpgradeDepthsByDieValue[5]!;

  set possibleUpgradeDepthDynamites(int depth) =>
      availableUpgradeDepthsByDieValue[1] = depth;
  set possibleUpgradeDepthMineCarts(int depth) =>
      availableUpgradeDepthsByDieValue[2] = depth;
  set possibleUpgradeDepthShivs(int depth) =>
      availableUpgradeDepthsByDieValue[3] = depth;
  set possibleUpgradeDepthPickaxes(int depth) =>
      availableUpgradeDepthsByDieValue[4] = depth;
  set possibleUpgradeDepthLunchboxes(int depth) =>
      availableUpgradeDepthsByDieValue[5] = depth;

  int get numDynamites => numPowerByDieValue[1]!;
  int get numMineCarts => numPowerByDieValue[2]!;
  int get numShivs => numPowerByDieValue[3]!;
  int get numPickaxes => numPowerByDieValue[4]!;
  int get numLunchboxes => numPowerByDieValue[5]!;

  set numDynamites(int num) => numPowerByDieValue[1] = num;
  set numMineCarts(int num) => numPowerByDieValue[2] = num;
  set numShivs(int num) => numPowerByDieValue[3] = num;
  set numPickaxes(int num) => numPowerByDieValue[4] = num;
  set numLunchboxes(int num) => numPowerByDieValue[5] = num;

  Map<int, int> numPowerByDieValue = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  int usedDynamites = 0;
  int usedMineCarts = 0;
  int usedShivs = 0;
  int usedPickaxes = 0;
  int usedLunchboxes = 0;

  List<int> mineCartDice = List.empty(growable: true);
  int mineCartGold = 0;

  Player(this.name, this.goldCount);
}
