import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/universe_config.dart';

// State sınıfı
class LevelProgressState {
  final Map<int, int> levelStars;
  final Map<int, bool> levelUnlocked;
  final bool isLoading;

  LevelProgressState({
    required this.levelStars,
    required this.levelUnlocked,
    this.isLoading = false,
  });

  LevelProgressState copyWith({
    Map<int, int>? levelStars,
    Map<int, bool>? levelUnlocked,
    bool? isLoading,
  }) {
    return LevelProgressState(
      levelStars: levelStars ?? this.levelStars,
      levelUnlocked: levelUnlocked ?? this.levelUnlocked,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Cubit sınıfı
class LevelProgressCubit extends Cubit<LevelProgressState> {
  // GameStatsCubit'e callback fonksiyonu
  Function()? onStarsUpdated;
  int _currentUniverseId = 1;

  LevelProgressCubit({this.onStarsUpdated}) : super(LevelProgressState(
    levelStars: {},
    levelUnlocked: {},
    isLoading: true,
  )) {
    _loadProgress();
  }

  // Progress'i SharedPreferences'tan yükle
  Future<void> _loadProgress() async {
    await _loadUniverseProgress(_currentUniverseId);
  }

  // Belirtilen evren için progress yükle
  Future<void> _loadUniverseProgress(int universeId) async {
    emit(state.copyWith(isLoading: true));
    
    final prefs = await SharedPreferences.getInstance();
    final Map<int, int> stars = {};
    final Map<int, bool> unlocked = {};

    // Level 1 her zaman açık
    unlocked[1] = true;
    stars[1] = prefs.getInt('universe_${universeId}_level_1_stars') ?? 0;

    // Diğer level'ları kontrol et
    for (int i = 2; i <= 50; i++) {
      unlocked[i] = prefs.getBool('universe_${universeId}_level_${i}_unlocked') ?? false;
      stars[i] = prefs.getInt('universe_${universeId}_level_${i}_stars') ?? 0;
    }

    emit(state.copyWith(
      levelStars: stars,
      levelUnlocked: unlocked,
      isLoading: false,
    ));

    print('=== CUBIT: Universe $universeId progress loaded ===');
    for (int i = 1; i <= 50; i++) {
      print('Level $i: Unlocked=${unlocked[i]}, Stars=${stars[i]}');
    }
  }

  // Level yıldızlarını güncelle
  Future<void> updateStars(int level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('universe_${_currentUniverseId}_level_${level}_stars', stars);

    final newStars = Map<int, int>.from(state.levelStars);
    newStars[level] = stars;

    emit(state.copyWith(levelStars: newStars));
    
    print('=== CUBIT: Universe $_currentUniverseId Level $level stars updated to $stars ===');
    
    // GameStatsCubit'e toplam yıldızları güncellemesi için bildir
    onStarsUpdated?.call();
  }

  // Level kilidini aç
  Future<void> unlockLevel(int level) async {
    if (level > 50) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('universe_${_currentUniverseId}_level_${level}_unlocked', true);

    final newUnlocked = Map<int, bool>.from(state.levelUnlocked);
    newUnlocked[level] = true;

    emit(state.copyWith(levelUnlocked: newUnlocked));
    
    print('=== CUBIT: Universe $_currentUniverseId Level $level unlocked ===');
  }

  // Level tamamlandığında çağrılacak fonksiyon
  Future<void> onLevelCompleted(int level, int elapsedSeconds) async {
    print('=== CUBIT: Level $level completed in $elapsedSeconds seconds ===');
    
    // Yıldız hesapla
    final stars = _calculateStars(elapsedSeconds);
    print('=== CUBIT: Calculated stars: $stars ===');
    
    // Yıldızları güncelle
    await updateStars(level, stars);
    
    // Bir sonraki level'ın kilidini aç
    if (level < 50) {
      await unlockLevel(level + 1);
    }
    
    print('=== CUBIT: Level completion processed ===');
  }

  // Yıldız hesaplama mantığı
  int _calculateStars(int elapsedSeconds) {
    // Yeni kural:
    // <45 sn => 3 yıldız
    // 45..70 sn (70 dahil) => 2 yıldız
    // >70 sn => 1 yıldız
    if (elapsedSeconds < 45) return 3;
    if (elapsedSeconds <= 70) return 2;
    return 1;
  }

  // Evren değiştir
  Future<void> switchUniverse(int universeId) async {
    print('=== CUBIT: Switching to universe $universeId ===');
    
    // Evren kilidini kontrol et
    final isUnlocked = await UniverseConfig.isUniverseUnlockedFromPrefs(universeId);
    if (!isUnlocked) {
      print('=== CUBIT: Universe $universeId is locked! ===');
      // Kilitli evrene geçiş yapma, mevcut evrende kal
      return;
    }
    
    _currentUniverseId = universeId;
    await _loadUniverseProgress(universeId);
  }

  // Tüm progress'i sıfırla
  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tüm level verilerini sil
    for (int i = 1; i <= 10; i++) {
      await prefs.remove('level_${i}_stars');
      await prefs.remove('level_${i}_unlocked');
    }
    
    // Level 1'i açık yap
    await prefs.setBool('level_1_unlocked', true);
    
    // State'i sıfırla
    final Map<int, int> stars = {1: 0};
    final Map<int, bool> unlocked = {1: true};
    
    for (int i = 2; i <= 10; i++) {
      stars[i] = 0;
      unlocked[i] = false;
    }
    
    emit(state.copyWith(
      levelStars: stars,
      levelUnlocked: unlocked,
    ));
    
    print('=== CUBIT: All progress reset ===');
  }

  // Progress'i yeniden yükle
  Future<void> refreshProgress() async {
    await _loadProgress();
  }
} 