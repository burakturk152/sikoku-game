import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/puzzle_data.dart';
import 'remote_puzzle_provider.dart';
import 'github_puzzle_provider.dart';

enum PuzzleSource { local, remote, hybrid, github }

class PuzzleLoaderService {
  final RemotePuzzleProvider? _remote;
  final GitHubPuzzleProvider? _github;
  final PuzzleSource source;

  PuzzleLoaderService({
    RemotePuzzleProvider? remote,
    GitHubPuzzleProvider? github,
    this.source = PuzzleSource.hybrid,
  }) : _remote = remote, _github = github;

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Future<PuzzleData> loadDailyPuzzle(DateTime dateLocal) async {
    // Sadece GitHub'dan çek
    if (_github == null) {
      throw Exception('GitHub provider not available');
    }
    
    final s = await _github!.fetchDaily(dateLocal);
    if (s == null) {
      throw Exception('Günlük bulmaca yüklenemedi');
    }
    
    return _parse(s);
  }

  Future<PuzzleData> loadWeeklyPuzzle(DateTime dateLocal) async {
    // Sadece GitHub'dan çek
    if (_github == null) {
      throw Exception('GitHub provider not available');
    }
    
    final s = await _github!.fetchWeekly(dateLocal);
    if (s == null) {
      throw Exception('Haftalık bulmaca bulunamadı');
    }
    
    return _parse(s);
  }

  // Cache'i temizle
  Future<void> clearCache() async {
    if (_github != null) {
      await _github!.clearCache();
    }
  }

  PuzzleData _parse(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    
    // GitHub'dan gelen puzzle'ları PuzzleData formatına dönüştür
    if (map.containsKey('puzzle') && map.containsKey('solution')) {
      return _convertGitHubPuzzleToPuzzleData(map);
    }
    
    // Eski format için normal parse
    return PuzzleData.fromJson(map);
  }

  PuzzleData _convertGitHubPuzzleToPuzzleData(Map<String, dynamic> jsonData) {
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

    // Puzzle'ı dönüştür (boş grid)
    List<List<int>> puzzle = [];
    for (int i = 0; i < (jsonData['size'] ?? 6); i++) {
      List<int> row = [];
      for (int j = 0; j < (jsonData['size'] ?? 6); j++) {
        row.add(0); // Boş hücreler
      }
      puzzle.add(row);
    }

    // Prefilled'ı bul (locked olan hücreler)
    List<List<int>> prefilled = [];
    if (jsonData.containsKey('puzzle')) {
      List<List<dynamic>> puzzleData = List<List<dynamic>>.from(jsonData['puzzle']);
      for (int i = 0; i < puzzleData.length; i++) {
        for (int j = 0; j < puzzleData[i].length; j++) {
          if (puzzleData[i][j] is Map && puzzleData[i][j]['locked'] == true) {
            prefilled.add([i, j]);
          }
        }
      }
    }

    // Hints'leri dönüştür
    List<List<int>> hintData = [];
    List<dynamic> hints = jsonData['hints'] ?? [];
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
      'horizontal': List.generate(jsonData['size'] ?? 6, (i) => List.generate((jsonData['size'] ?? 6) - 1, (j) => null)),
      'vertical': List.generate((jsonData['size'] ?? 6) - 1, (i) => List.generate(jsonData['size'] ?? 6, (j) => null)),
    };

    return PuzzleData(
      stage: 0, // Günlük/haftalık puzzle'lar için stage 0
      level: jsonData['level'] ?? 1,
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

  static Future<PuzzleData> loadUniverseLevelAsPuzzleData(int universeId, int level) async {
    // Mevcut evren sistemi için fallback
    // Bu metod eski sistemi korur
    throw UnimplementedError('loadUniverseLevelAsPuzzleData - Evren sistemi için ayrı implementasyon gerekli');
  }
}