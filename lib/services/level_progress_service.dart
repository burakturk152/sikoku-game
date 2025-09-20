import 'package:shared_preferences/shared_preferences.dart';

class LevelProgressService {
  // Yıldız hesaplama
  static int calculateStars(int completionTimeSeconds) {
    if (completionTimeSeconds <= 30) return 3;
    if (completionTimeSeconds <= 45) return 2;
    return 1;
  }

  // Level yıldızlarını kaydet
  static Future<void> setStars(int level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level_${level}_stars', stars);
  }

  // Level yıldızlarını getir
  static Future<int> getStars(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level_${level}_stars') ?? 0;
  }

  // Level kilidini aç
  static Future<void> unlockLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_${level}_unlocked', true);
  }

  // Level kilit durumunu getir
  static Future<bool> isLevelUnlocked(int level) async {
    final prefs = await SharedPreferences.getInstance();
    // Sadece Level 1 açık, diğerleri kilitli
    if (level == 1) return true;
    return prefs.getBool('level_${level}_unlocked') ?? false;
  }

  // Level tamamlandığında çağrılacak fonksiyon
  static Future<void> onLevelCompleted(int level, int elapsedSeconds) async {
    print('=== LEVEL COMPLETION DEBUG ===');
    print('Level $level completed in $elapsedSeconds seconds');
    
    // Yıldız hesapla
    final stars = calculateStars(elapsedSeconds);
    print('Calculated stars: $stars');
    
    // Yıldızları kaydet
    await setStars(level, stars);
    print('Stars saved for level $level');
    
    // Bir sonraki level'ın kilidini aç
    if (level < 50) {
      final nextLevel = level + 1;
      print('Unlocking level $nextLevel...');
      await unlockLevel(nextLevel);
      
      // Kontrol et
      final isUnlocked = await isLevelUnlocked(nextLevel);
      print('Level $nextLevel unlocked: $isUnlocked');
    }
    
    print('=== LEVEL COMPLETION END ===');
  }

  // Tüm progress'i sıfırla
  static Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('level_')) {
        await prefs.remove(key);
      }
    }
    
    // Level 1'i açık bırak
    await unlockLevel(1);
  }

  // İlk kurulum için - sadece Level 1 açık
  static Future<void> initializeLevels() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tüm level'ları kilitli yap
    for (int i = 2; i <= 50; i++) {
      await prefs.setBool('level_${i}_unlocked', false);
    }
    
    // Level 1'i açık yap
    await prefs.setBool('level_1_unlocked', true);
    
    // Tüm yıldız verilerini sıfırla
    for (int i = 1; i <= 50; i++) {
      await prefs.remove('level_${i}_stars');
    }
  }
} 