import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  // Yıldız hesaplama
  static int calculateStars(int completionTimeSeconds) {
    if (completionTimeSeconds <= 30) return 3;
    if (completionTimeSeconds <= 45) return 2;
    return 1;
  }

  // Level yıldızlarını kaydet
  static Future<void> saveLevelStars(int stage, int level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${level}_stars';
    await prefs.setInt(key, stars);
    
    // Bir sonraki level'ın kilidini aç
    if (stars >= 1) {
      await unlockNextLevel(stage, level + 1);
    }
  }

  // Level yıldızlarını getir
  static Future<int> getLevelStars(int stage, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${level}_stars';
    return prefs.getInt(key) ?? 0;
  }

  // Level kilit durumunu kaydet
  static Future<void> setLevelLock(int stage, int level, bool isLocked) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${level}_unlocked';
    await prefs.setBool(key, !isLocked);
  }

  // Level kilit durumunu getir
  static Future<bool> isLevelLocked(int stage, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${level}_unlocked';
    return !(prefs.getBool(key) ?? (level == 1)); // Level 1 hariç hepsi kilitli
  }

  // Bir sonraki level'ın kilidini aç
  static Future<void> unlockNextLevel(int stage, int nextLevel) async {
    if (nextLevel <= 50) {
      await setLevelLock(stage, nextLevel, false);
      print('DEBUG: Level $nextLevel unlocked for stage $stage');
    }
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
    await setLevelLock(1, 1, false);
  }
} 