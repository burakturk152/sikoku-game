import 'package:flutter/material.dart';

class CountersWidget {
  // Sayaç hesaplama fonksiyonları
  static List<int> getRowCounts(List<List<int>> gridState, int row) {
    int blueCount = 0;
    int yellowCount = 0;
    for (int col = 0; col < gridState[row].length; col++) {
      if (gridState[row][col] == 1) blueCount++;
      if (gridState[row][col] == 2) yellowCount++;
    }
    return [blueCount, yellowCount];
  }
  
  static List<int> getColumnCounts(List<List<int>> gridState, int col) {
    int blueCount = 0;
    int yellowCount = 0;
    for (int row = 0; row < gridState.length; row++) {
      if (gridState[row][col] == 1) blueCount++;
      if (gridState[row][col] == 2) yellowCount++;
    }
    return [blueCount, yellowCount];
  }

  static Widget buildCounter(String text, double fontSize, Color counterColor) {
    return Container(
      width: double.infinity,
      child: Text(
        text,
        style: TextStyle(
          color: counterColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
} 