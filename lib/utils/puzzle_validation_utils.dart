import '../bloc/puzzle_states.dart';

class PuzzleValidationUtils {
  static bool isPuzzleSolved(List<List<int>> gridState, List<List<int>> solution) {
    for (int row = 0; row < gridState.length; row++) {
      for (int col = 0; col < gridState[row].length; col++) {
        if (gridState[row][col] != solution[row][col]) {
          return false;
        }
      }
    }
    return true;
  }

  static List<String> validateGrid(List<List<int>> gridState, PuzzleLoaded state) {
    List<String> errors = [];
    int targetCount = state.gridSize ~/ 2;
    
    // Her satırda eşit miktarda mavi ve sarı kontrolü
    for (int row = 0; row < state.gridSize; row++) {
      int blueCount = 0;
      int yellowCount = 0;
      for (int col = 0; col < state.gridSize; col++) {
        if (gridState[row][col] == 1) blueCount++;
        if (gridState[row][col] == 2) yellowCount++;
      }
      if (blueCount != targetCount || yellowCount != targetCount) {
        errors.add('Satır ${row + 1}: Eşit miktarda mavi ve sarı olmalı');
      }
    }
    
    // Her sütunda eşit miktarda mavi ve sarı kontrolü
    for (int col = 0; col < state.gridSize; col++) {
      int blueCount = 0;
      int yellowCount = 0;
      for (int row = 0; row < state.gridSize; row++) {
        if (gridState[row][col] == 1) blueCount++;
        if (gridState[row][col] == 2) yellowCount++;
      }
      if (blueCount != targetCount || yellowCount != targetCount) {
        errors.add('Sütun ${col + 1}: Eşit miktarda mavi ve sarı olmalı');
      }
    }
    
    // 3 aynı renk arka arkaya gelme kontrolü
    for (int row = 0; row < state.gridSize; row++) {
      for (int col = 0; col < state.gridSize - 2; col++) {
        if (gridState[row][col] != 0 && 
            gridState[row][col] == gridState[row][col + 1] && 
            gridState[row][col] == gridState[row][col + 2]) {
          errors.add('3 aynı renk arka arkaya gelemez');
        }
      }
    }
    
    for (int col = 0; col < state.gridSize; col++) {
      for (int row = 0; row < state.gridSize - 2; row++) {
        if (gridState[row][col] != 0 && 
            gridState[row][col] == gridState[row + 1][col] && 
            gridState[row][col] == gridState[row + 2][col]) {
          errors.add('3 aynı renk arka arkaya gelemez');
        }
      }
    }
    
    // Sembol kuralları kontrolü
    for (int row = 0; row < state.gridSize; row++) {
      for (int col = 0; col < state.gridSize - 1; col++) {
        if (state.horizontalSymbols[row][col] == '=') {
          if (gridState[row][col] != gridState[row][col + 1] || 
              gridState[row][col] == 0 || gridState[row][col + 1] == 0) {
            errors.add('Sembol kuralı ihlal edildi');
          }
        } else if (state.horizontalSymbols[row][col] == '⚡') {
          if (gridState[row][col] == gridState[row][col + 1] || 
              gridState[row][col] == 0 || gridState[row][col + 1] == 0) {
            errors.add('Sembol kuralı ihlal edildi');
          }
        }
      }
    }
    
    for (int row = 0; row < state.gridSize - 1; row++) {
      for (int col = 0; col < state.gridSize; col++) {
        if (state.verticalSymbols[row][col] == '=') {
          if (gridState[row][col] != gridState[row + 1][col] || 
              gridState[row][col] == 0 || gridState[row + 1][col] == 0) {
            errors.add('Sembol kuralı ihlal edildi');
          }
        } else if (state.verticalSymbols[row][col] == '⚡') {
          if (gridState[row][col] == gridState[row + 1][col] || 
              gridState[row][col] == 0 || gridState[row + 1][col] == 0) {
            errors.add('Sembol kuralı ihlal edildi');
          }
        }
      }
    }
    
    return errors;
  }
} 