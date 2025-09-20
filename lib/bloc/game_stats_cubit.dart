import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/universe_config.dart';

class GameStatsState extends Equatable {
  final int dailyCompleted;
  final int weeklyCompleted;
  final int totalStars;
  final int fastestTime;
  final int perfectPuzzles;
  final List<int> unlockedLevels;
  final bool isLoading;
  final int currentUniverseId; // Mevcut evren ID'si

  const GameStatsState({
    required this.dailyCompleted,
    required this.weeklyCompleted,
    required this.totalStars,
    required this.fastestTime,
    required this.perfectPuzzles,
    required this.unlockedLevels,
    this.isLoading = false,
    this.currentUniverseId = 1, // Varsayılan olarak Evren 1
  });

  factory GameStatsState.initial() => const GameStatsState(
        dailyCompleted: 0,
        weeklyCompleted: 0,
        totalStars: 0,
        fastestTime: 9999,
        perfectPuzzles: 0,
        unlockedLevels: [1],
        currentUniverseId: 1,
      );

  GameStatsState copyWith({
    int? dailyCompleted,
    int? weeklyCompleted,
    int? totalStars,
    int? fastestTime,
    int? perfectPuzzles,
    List<int>? unlockedLevels,
    bool? isLoading,
    int? currentUniverseId,
  }) {
    return GameStatsState(
      dailyCompleted: dailyCompleted ?? this.dailyCompleted,
      weeklyCompleted: weeklyCompleted ?? this.weeklyCompleted,
      totalStars: totalStars ?? this.totalStars,
      fastestTime: fastestTime ?? this.fastestTime,
      perfectPuzzles: perfectPuzzles ?? this.perfectPuzzles,
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
      isLoading: isLoading ?? this.isLoading,
      currentUniverseId: currentUniverseId ?? this.currentUniverseId,
    );
  }

  @override
  List<Object?> get props => [
        dailyCompleted,
        weeklyCompleted,
        totalStars,
        fastestTime,
        perfectPuzzles,
        unlockedLevels,
        isLoading,
        currentUniverseId,
      ];
}

class GameStatsCubit extends Cubit<GameStatsState> {
  static const String _statsKey = 'game_stats';
  static const String _universeStatsKey = 'universe_stats';
  
  GameStatsCubit() : super(GameStatsState.initial()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    await _loadUniverseStats(1); // Varsayılan olarak Evren 1'i yükle
  }

  // Belirtilen evren için progress yükle
  Future<void> _loadUniverseStats(int universeId) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final universeStatsJson = prefs.getString('${_universeStatsKey}_$universeId');
      
      if (universeStatsJson != null) {
        final Map<String, dynamic> stats = json.decode(universeStatsJson);
        
        emit(GameStatsState(
          dailyCompleted: stats['dailyCompleted'] ?? 0,
          weeklyCompleted: stats['weeklyCompleted'] ?? 0,
          totalStars: stats['totalStars'] ?? 0,
          fastestTime: stats['fastestTime'] ?? 9999,
          perfectPuzzles: stats['perfectPuzzles'] ?? 0,
          unlockedLevels: List<int>.from(stats['unlockedLevels'] ?? [1]),
          currentUniverseId: stats['currentUniverseId'] ?? universeId,
          isLoading: false,
        ));
      } else {
        // İlk kez açılıyorsa default değerler
        final initialState = GameStatsState.initial();
        await _saveUniverseStats(universeId, initialState);
        emit(initialState.copyWith(isLoading: false));
      }
      
      // Yükleme tamamlandıktan sonra toplam yıldızları güncelle
      await updateTotalStarsFromLevelProgress();
    } catch (e) {
      print('Error loading universe $universeId stats: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _saveStats(GameStatsState stats) async {
    await _saveUniverseStats(stats.currentUniverseId, stats); // Mevcut evreni kaydet
  }

  // Belirtilen evren için progress kaydet
  Future<void> _saveUniverseStats(int universeId, GameStatsState stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsData = {
        'dailyCompleted': stats.dailyCompleted,
        'weeklyCompleted': stats.weeklyCompleted,
        'totalStars': stats.totalStars,
        'fastestTime': stats.fastestTime,
        'perfectPuzzles': stats.perfectPuzzles,
        'unlockedLevels': stats.unlockedLevels,
        'currentUniverseId': stats.currentUniverseId,
      };
      
      await prefs.setString('${_universeStatsKey}_$universeId', json.encode(statsData));
    } catch (e) {
      print('Error saving universe $universeId stats: $e');
    }
  }

  // Level tamamlandığında çağrılacak ana fonksiyon
  Future<void> onLevelCompleted(int level, int elapsedSeconds, {bool isDaily = false, bool isWeekly = false}) async {
    print('=== GAME STATS: Level $level completed in $elapsedSeconds seconds ===');
    
    // Yıldız hesapla
    final stars = _calculateStars(elapsedSeconds);
    print('=== GAME STATS: Calculated stars: $stars ===');
    
    // Yeni state oluştur
    var newState = state.copyWith(
      totalStars: state.totalStars + stars,
    );
    
    // En hızlı zamanı güncelle
    if (elapsedSeconds < state.fastestTime) {
      newState = newState.copyWith(fastestTime: elapsedSeconds);
    }
    
    // Mükemmel puzzle sayısını güncelle (3 yıldız)
    if (stars == 3) {
      newState = newState.copyWith(perfectPuzzles: state.perfectPuzzles + 1);
    }
    
    // Günlük/Haftalık sayaçları güncelle
    if (isDaily) {
      newState = newState.copyWith(dailyCompleted: state.dailyCompleted + 1);
    } else if (isWeekly) {
      newState = newState.copyWith(weeklyCompleted: state.weeklyCompleted + 1);
    }
    
    // Level kilidini aç
    if (!newState.unlockedLevels.contains(level + 1) && level < 50) {
      final newUnlockedLevels = List<int>.from(newState.unlockedLevels)..add(level + 1);
      newState = newState.copyWith(unlockedLevels: newUnlockedLevels);
      print('=== GAME STATS: Level ${level + 1} unlocked ===');
    }
    
    // Eğer level 50 tamamlandıysa sonraki evreni aç
    if (level == 50) {
      await _unlockNextUniverse();
    }
    
    // State'i güncelle
    emit(newState);
    
    // Kalıcı olarak kaydet
    await _saveStats(newState);
    
    print('=== GAME STATS: Stats updated and saved ===');
    print('Total Stars: ${newState.totalStars}');
    print('Unlocked Levels: ${newState.unlockedLevels}');
  }

  // Yıldız hesaplama mantığı
  int _calculateStars(int elapsedSeconds) {
    if (elapsedSeconds <= 10) return 3;
    if (elapsedSeconds <= 20) return 2;
    if (elapsedSeconds <= 30) return 1;
    return 0;
  }

  // Günlük puzzle tamamlandığında
  Future<void> onDailyCompleted(int elapsedSeconds) async {
    await onLevelCompleted(1, elapsedSeconds, isDaily: true);
  }

  // Haftalık puzzle tamamlandığında
  Future<void> onWeeklyCompleted(int elapsedSeconds) async {
    await onLevelCompleted(1, elapsedSeconds, isWeekly: true);
  }

  // Level kilidini manuel olarak aç
  Future<void> unlockLevel(int level) async {
    if (state.unlockedLevels.contains(level)) return;
    
    final newUnlockedLevels = List<int>.from(state.unlockedLevels)..add(level);
    final newState = state.copyWith(unlockedLevels: newUnlockedLevels);
    
    emit(newState);
    await _saveStats(newState);
  }

  // İstatistikleri sıfırla
  Future<void> resetStats() async {
    final initialState = GameStatsState.initial();
    emit(initialState);
    await _saveStats(initialState);
  }

  // Belirli bir level'ın açık olup olmadığını kontrol et
  bool isLevelUnlocked(int level) {
    return state.unlockedLevels.contains(level);
  }

  // Evren değiştir
  Future<void> switchUniverse(int universeId) async {
    print('=== GAME STATS: Switching to universe $universeId ===');
    
    // Evren kilidini kontrol et
    final isUnlocked = await UniverseConfig.isUniverseUnlockedFromPrefs(universeId);
    if (!isUnlocked) {
      print('=== GAME STATS: Universe $universeId is locked! ===');
      // Kilitli evrene geçiş yapma, mevcut evrende kal
      return;
    }
    
    // Mevcut evren ID'sini güncelle
    emit(state.copyWith(currentUniverseId: universeId));
    
    await _loadUniverseStats(universeId);
  }

  // Sonraki evreni aç
  Future<void> _unlockNextUniverse() async {
    // Mevcut evren ID'sini al
    final currentUniverseId = state.currentUniverseId;
    final nextUniverseId = currentUniverseId + 1;
    
    try {
      await UniverseConfig.unlockUniverse(nextUniverseId);
      print('=== GAME STATS: Universe $nextUniverseId unlocked! ===');
      
      // Otomatik olarak sonraki evrene geç
      await switchUniverse(nextUniverseId);
    } catch (e) {
      print('=== GAME STATS: Error unlocking next universe: $e ===');
    }
  }

  // Belirli bir level'ın yıldız sayısını al
  int getLevelStars(int level) {
    // Bu fonksiyon şimdilik 0 döndürüyor, çünkü level bazlı yıldızları 
    // LevelProgressCubit yönetiyor. İleride buraya da eklenebilir.
    return 0;
  }

  // LevelProgressCubit'ten tüm yıldızları oku ve toplam yıldız sayısını güncelle
  Future<void> updateTotalStarsFromLevelProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int totalStars = 0;
      
      // Tüm level'ları tara (1-10)
      for (int i = 1; i <= 10; i++) {
        final stars = prefs.getInt('level_${i}_stars') ?? 0;
        totalStars += stars;
      }
      
      // State'i güncelle
      final newState = state.copyWith(totalStars: totalStars);
      emit(newState);
      
      // Kalıcı olarak kaydet
      await _saveStats(newState);
      
      print('=== GAME STATS: Total stars updated to $totalStars ===');
    } catch (e) {
      print('Error updating total stars: $e');
    }
  }

  // İstatistikleri yeniden yükle ve toplam yıldızları güncelle
  Future<void> refreshStats() async {
    await _loadStats();
    await updateTotalStarsFromLevelProgress();
  }
}
