import 'package:flutter/foundation.dart';

enum UniverseKind { space, forest } // 1=Space, 2=Forest

@immutable
class CellIconSet {
  final String blue;  // mavi hücre (0/1 veya senin blue value'n neyse)
  final String yellow; // sarı hücre
  const CellIconSet({required this.blue, required this.yellow});
}

const CellIconSet spaceIcons = CellIconSet(
  blue: 'assets/images/earth.png',
  yellow: 'assets/images/sunny.png',
);

const CellIconSet forestIcons = CellIconSet(
  blue: 'assets/images/blueberry.png',
  yellow: 'assets/images/banana.png',
);

CellIconSet iconsForUniverse(UniverseKind kind) {
  switch (kind) {
    case UniverseKind.forest:
      return forestIcons;
    case UniverseKind.space:
    default:
      return spaceIcons;
  }
}
