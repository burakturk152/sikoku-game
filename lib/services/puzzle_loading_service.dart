import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_events.dart';
import '../services/puzzle_loader_service.dart';
import '../services/puzzle_service.dart';
import '../services/github_puzzle_provider.dart';
import '../models/puzzle_data.dart';

class PuzzleLoadingService {
  static Future<void> loadPuzzle({
    required BuildContext context,
    required int level,
    required int stage,
    required Function(bool) setLoading,
    required Function(List<List<int>>?) setHints,
    required Function(int) setMaxTime,
    required VoidCallback startTimer,
    required Function(PuzzleData) printSolution,
    DateTime? dailyDate,
    DateTime? weeklyMonday,
  }) async {
    try {
      setLoading(true);
      PuzzleData currentPuzzle;
      final puzzleLoader = PuzzleLoaderService(
        github: GitHubPuzzleProvider(),
        source: PuzzleSource.github,
      );
      
      if (dailyDate != null) {
        currentPuzzle = await puzzleLoader.loadDailyPuzzle(dailyDate);
      } else if (weeklyMonday != null) {
        currentPuzzle = await puzzleLoader.loadWeeklyPuzzle(weeklyMonday);
      } else {
        // Evren sistemine göre level yükleme - eski sistemi kullan
        final puzzle = await PuzzleService.getPuzzle(stage, level);
        if (puzzle == null) {
          throw Exception('Level $level bulunamadı');
        }
        currentPuzzle = puzzle;
      }
      setHints(currentPuzzle.hintData);
      setMaxTime(currentPuzzle.maxTimeSeconds ?? 60);
      
      if (context.mounted) {
        try {
          final bloc = context.read<PuzzleBloc>();
          bloc.add(PuzzleLoad(
            stage: (dailyDate != null || weeklyMonday != null) ? 0 : stage, // Günlük/haftalık için stage 0
            level: currentPuzzle.level,
            gridSize: currentPuzzle.gridSize,
            solution: currentPuzzle.solution,
            horizontalSymbols: currentPuzzle.symbols['horizontal']!,
            verticalSymbols: currentPuzzle.symbols['vertical']!,
            prefilled: currentPuzzle.prefilled,
          ));
        } catch (e) {
          print('Bloc yükleme hatası: $e');
          createDefaultPuzzle(context, stage, level);
        }
      }
      
      setLoading(false);
      startTimer();
      printSolution(currentPuzzle);
    } catch (e) {
      print('Bulmaca yükleme hatası: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              dailyDate != null
                  ? 'Bugünün bulmacası yüklenemedi: $e'
                  : weeklyMonday != null
                      ? 'Bu haftanın bulmacası yüklenemedi: $e'
                      : 'Level $level yüklenirken hata oluştu: $e',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Geri Dön',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
      if (dailyDate == null) {
        createDefaultPuzzle(context, stage, level);
      }
    }
  }

  static void createDefaultPuzzle(BuildContext context, int stage, int level) {
    if (context.mounted) {
      try {
        final bloc = context.read<PuzzleBloc>();
        bloc.add(PuzzleLoad(
          stage: stage,
          level: level,
          gridSize: 6,
          solution: [
            [1, 2, 2, 1, 2, 1],
            [1, 2, 2, 1, 1, 2],
            [2, 1, 1, 2, 1, 2],
            [1, 2, 1, 2, 2, 1],
            [2, 1, 2, 1, 1, 2],
            [2, 1, 1, 2, 2, 1],
          ],
          horizontalSymbols: List.generate(6, (i) => List.generate(5, (j) => null)),
          verticalSymbols: List.generate(5, (i) => List.generate(6, (j) => null)),
          prefilled: [[0, 0], [0, 1], [1, 0], [1, 1], [2, 2], [3, 3]],
        ));
      } catch (e) {
        print('Varsayılan puzzle oluşturma hatası: $e');
      }
    }
  }
} 