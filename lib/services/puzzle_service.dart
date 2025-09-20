import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/puzzle_data.dart';

class PuzzleService {
  static Map<String, PuzzleData>? _puzzles;
  
  // Tüm bulmacaları yükle
  static Future<Map<String, PuzzleData>> loadPuzzles() async {
    if (_puzzles != null) return _puzzles!;
    
    try {
      _puzzles = {};
      
      // Stage 1 level'larını yükle
      for (int level = 1; level <= 50; level++) {
        try {
          final String jsonString = await rootBundle.loadString('assets/data/stage1/level_$level.json');
          final Map<String, dynamic> jsonData = json.decode(jsonString);
          _puzzles!['1_$level'] = _convertToPuzzleData(jsonData, 1, level);
        } catch (e) {
          // Level bulunamadı, devam et
        }
      }
      
      // Stage 2 level'larını yükle
      for (int level = 1; level <= 26; level++) {
        try {
          final String jsonString = await rootBundle.loadString('assets/data/stage2/level_$level.json');
          final Map<String, dynamic> jsonData = json.decode(jsonString);
          _puzzles!['2_$level'] = _convertToPuzzleData(jsonData, 2, level);
        } catch (e) {
          // Level bulunamadı, devam et
        }
      }
      
      return _puzzles!;
    } catch (e) {
      print('Bulmaca yükleme hatası: $e');
      return {};
    }
  }
  
  // Belirli bir bulmacayı getir
  static Future<PuzzleData?> getPuzzle(int stage, int level) async {
    final puzzles = await loadPuzzles();
    final key = '${stage}_$level';
    return puzzles[key];
  }
  
  // Stage'deki tüm bulmacaları getir
  static Future<List<PuzzleData>> getPuzzlesByStage(int stage) async {
    final puzzles = await loadPuzzles();
    return puzzles.values.where((puzzle) => puzzle.stage == stage).toList();
  }
  
  // Toplam bulmaca sayısını getir
  static Future<int> getTotalPuzzleCount() async {
    final puzzles = await loadPuzzles();
    return puzzles.length;
  }
  
  // Zorluk seviyesine göre bulmacaları getir
  static Future<List<PuzzleData>> getPuzzlesByDifficulty(int difficulty) async {
    final puzzles = await loadPuzzles();
    return puzzles.values.where((puzzle) => puzzle.difficulty == difficulty).toList();
  }

  // JSON formatını PuzzleData formatına dönüştür
  static PuzzleData _convertToPuzzleData(Map<String, dynamic> jsonData, int stage, int level) {
    // Solution'ı dönüştür
    List<List<int>> solution = [];
    for (var row in jsonData['solution']) {
      List<int> intRow = [];
      for (var cell in row) {
        // String değerleri int'e dönüştür
        int value = 0;
        if (cell == 'yellow_triangle') value = 1;
        else if (cell == 'blue_square') value = 2;
        intRow.add(value);
      }
      solution.add(intRow);
    }

    // Prefilled'ı bul (locked olan hücreler)
    List<List<int>> prefilled = [];
    List<List<dynamic>> puzzle = List<List<dynamic>>.from(jsonData['puzzle']);
    for (int i = 0; i < puzzle.length; i++) {
      for (int j = 0; j < puzzle[i].length; j++) {
        if (puzzle[i][j]['locked'] == true) {
          prefilled.add([i, j]);
        }
      }
    }

    // Hints'leri dönüştür
    List<List<int>> hintData = [];
    List<dynamic> hints = jsonData['hints'];
    for (var hint in hints) {
      List<int> hintRow = [];
      hintRow.add(hint['cell1'][0]); // row1
      hintRow.add(hint['cell1'][1]); // col1
      hintRow.add(hint['cell2'][0]); // row2
      hintRow.add(hint['cell2'][1]); // col2
      hintRow.add(hint['type'] == 'equal' ? 0 : 1); // 0=equal, 1=not_equal
      hintData.add(hintRow);
    }

    // Symbols'ı oluştur (boş)
    Map<String, List<List<String?>>> symbols = {
      'horizontal': List.generate(6, (i) => List.generate(5, (j) => null)),
      'vertical': List.generate(5, (i) => List.generate(6, (j) => null)),
    };

    return PuzzleData(
      stage: stage,
      level: level,
      gridSize: jsonData['size'] ?? 6,
      solution: solution,
      symbols: symbols,
      difficulty: 1, // Varsayılan zorluk
      prefilled: prefilled,
      hint: null,
      hints: null,
      hintData: hintData,
      maxTimeSeconds: 300, // 5 dakika varsayılan
    );
  }
} 