const int dicePerRoll = 5;

const Map<int, int> diceRequiredForDynamiteLevel = {
  1: 1,
  2: 2,
  3: 3,
  4: 4,
  5: 5
};
const Map<int, int> diceRequiredForMinecartLevel = {
  1: 1,
  2: 2,
  3: 3,
  4: 4,
  5: 5
};
const Map<int, int> diceRequiredForShivLevel = {1: 1, 2: 3, 3: 5, 4: 7, 5: 10};
const Map<int, int> diceRequiredForPickaxeLevel = {
  1: 1,
  2: 2,
  3: 4,
  4: 7,
  5: 10
};
const Map<int, int> diceRequiredForLunchboxLevel = {
  1: 2,
  2: 4,
  3: 6,
  4: 8,
  5: 10
};
Map<int, int> goldPerDie = {1: 1, 2: 2, 3: 3, 4: 5, 5: 7, 6: 10};

Map<int, Map<int, int>> diceRequiredForLevelByDieValue = {
  1: diceRequiredForDynamiteLevel,
  2: diceRequiredForMinecartLevel,
  3: diceRequiredForShivLevel,
  4: diceRequiredForPickaxeLevel,
  5: diceRequiredForLunchboxLevel
};
