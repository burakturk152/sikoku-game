import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_game/services/puzzle_service.dart';
import 'package:puzzle_game/models/puzzle_data.dart';

void main() {
  group('PuzzleService Tests', () {
    test('loadPuzzles should return non-empty map', () async {
      final puzzles = await PuzzleService.loadPuzzles();
      expect(puzzles, isNotEmpty);
    });

    test('getPuzzle should return puzzle for valid stage and level', () async {
      final puzzle = await PuzzleService.getPuzzle(1, 1);
      expect(puzzle, isNotNull);
      expect(puzzle!.stage, equals(1));
      expect(puzzle.level, equals(1));
    });

    test('getPuzzle should return null for invalid stage and level', () async {
      final puzzle = await PuzzleService.getPuzzle(999, 999);
      expect(puzzle, isNull);
    });

    test('getPuzzlesByStage should return puzzles for valid stage', () async {
      final puzzles = await PuzzleService.getPuzzlesByStage(1);
      expect(puzzles, isNotEmpty);
      for (final puzzle in puzzles) {
        expect(puzzle.stage, equals(1));
      }
    });

    test('getTotalPuzzleCount should return positive number', () async {
      final count = await PuzzleService.getTotalPuzzleCount();
      expect(count, greaterThan(0));
    });

    test('getPuzzlesByDifficulty should return puzzles for valid difficulty', () async {
      final puzzles = await PuzzleService.getPuzzlesByDifficulty(1);
      expect(puzzles, isNotEmpty);
      for (final puzzle in puzzles) {
        expect(puzzle.difficulty, equals(1));
      }
    });
  });
} 