import '../models/puzzle_data.dart';

class PuzzleDebugUtils {
  static void printSolution(PuzzleData puzzle) {
    print("=== SOLUTION GRID ===");
    print("Stage: ${puzzle.stage}, Level: ${puzzle.level}");
    for (int row = 0; row < puzzle.gridSize; row++) {
      String rowStr = "Row $row: ";
      for (int col = 0; col < puzzle.gridSize; col++) {
        if (puzzle.solution[row][col] == 1) {
          rowStr += "🔵 ";
        } else if (puzzle.solution[row][col] == 2) {
          rowStr += "🟡 ";
        } else {
          rowStr += "⚫ ";
        }
      }
      print(rowStr);
    }
    print("===================");
  }
} 