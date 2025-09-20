import 'package:flutter/material.dart';
import 'puzzle_loader_service.dart';
import 'github_puzzle_provider.dart';
import 'remote_puzzle_provider.dart';

class PuzzlePrefetchService {
  final PuzzleLoaderService loader;
  
  PuzzlePrefetchService({
    PuzzleLoaderService? loader,
    GitHubPuzzleProvider? github,
    RemotePuzzleProvider? remote,
    PuzzleSource source = PuzzleSource.hybrid,
  }) : loader = loader ?? PuzzleLoaderService(
    github: github ?? GitHubPuzzleProvider(),
    remote: remote ?? RemotePuzzleProvider(),
    source: source,
  );

  Future<void> prefetchTodayAndThisWeek() async {
    final now = DateTime.now();
    
    try {
      // Günlük puzzle'ı prefetch et
      await loader.loadDailyPuzzle(now);
      debugPrint('Daily puzzle prefetched successfully');
    } catch (e) {
      debugPrint('Daily puzzle prefetch failed: $e');
    }
    
    try {
      // Haftalık puzzle'ı prefetch et
      await loader.loadWeeklyPuzzle(now);
      debugPrint('Weekly puzzle prefetched successfully');
    } catch (e) {
      debugPrint('Weekly puzzle prefetch failed: $e');
    }
  }

  Future<void> prefetchSpecificDate(DateTime date) async {
    try {
      await loader.loadDailyPuzzle(date);
      debugPrint('Daily puzzle for ${date.toString()} prefetched successfully');
    } catch (e) {
      debugPrint('Daily puzzle prefetch for ${date.toString()} failed: $e');
    }
  }

  Future<void> prefetchWeeklyForDate(DateTime date) async {
    try {
      await loader.loadWeeklyPuzzle(date);
      debugPrint('Weekly puzzle for ${date.toString()} prefetched successfully');
    } catch (e) {
      debugPrint('Weekly puzzle prefetch for ${date.toString()} failed: $e');
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}
