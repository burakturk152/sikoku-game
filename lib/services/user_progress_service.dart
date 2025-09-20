import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProgress {
  final int openedStage;
  final int openedLevel;
  final Map<String, int> stars;
  final int hints;
  final int undos;
  final bool tutorialSeen;

  UserProgress({
    required this.openedStage,
    required this.openedLevel,
    required this.stars,
    required this.hints,
    required this.undos,
    required this.tutorialSeen,
  });

  Map<String, dynamic> toJson() {
    return {
      'openedStage': openedStage,
      'openedLevel': openedLevel,
      'stars': stars,
      'hints': hints,
      'undos': undos,
      'tutorialSeen': tutorialSeen,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      openedStage: json['openedStage'] ?? 1,
      openedLevel: json['openedLevel'] ?? 1,
      stars: Map<String, int>.from(json['stars'] ?? {}),
      hints: json['hints'] ?? 10,
      undos: json['undos'] ?? 5,
      tutorialSeen: json['tutorialSeen'] ?? false,
    );
  }

  factory UserProgress.defaultProgress() {
    return UserProgress(
      openedStage: 1,
      openedLevel: 1,
      stars: {},
      hints: 10,
      undos: 5,
      tutorialSeen: false,
    );
  }
}

class UserProgressService {
  static const String _progressKey = 'user_progress';
  static const String _starsKey = 'stars';
  static const String _hintsKey = 'hints';
  static const String _undosKey = 'undos';
  static const String _tutorialSeenKey = 'tutorial_seen';

  // Kaydedilen verileri oku
  static Future<UserProgress> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);
      
      if (progressJson != null) {
        final progressMap = json.decode(progressJson);
        return UserProgress.fromJson(progressMap);
      }
    } catch (e) {
      print('Progress yükleme hatası: $e');
    }
    
    // Varsayılan değerleri döndür
    return UserProgress.defaultProgress();
  }

  // Yeni verileri kaydet
  static Future<void> saveProgress(UserProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(progress.toJson());
      await prefs.setString(_progressKey, progressJson);
    } catch (e) {
      print('Progress kaydetme hatası: $e');
    }
  }

  // Verileri sıfırla
  static Future<void> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
    } catch (e) {
      print('Progress sıfırlama hatası: $e');
    }
  }

  // Bölüm 2'nin kilidini kaldır
  static Future<void> unlockStage2() async {
    try {
      final progress = await loadProgress();
      final updatedProgress = UserProgress(
        openedStage: 2,
        openedLevel: progress.openedLevel,
        stars: progress.stars,
        hints: progress.hints,
        undos: progress.undos,
        tutorialSeen: progress.tutorialSeen,
      );
      await saveProgress(updatedProgress);
      print('Bölüm 2 kilidi kaldırıldı!');
    } catch (e) {
      print('Bölüm 2 kilidi kaldırma hatası: $e');
    }
  }

  // Belirli bir stage-level için yıldız kaydet
  static Future<void> saveStar(int stage, int level, int starCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final starsJson = prefs.getString(_starsKey);
      Map<String, int> stars = {};
      
      if (starsJson != null) {
        stars = Map<String, int>.from(json.decode(starsJson));
      }
      
      stars['$stage-$level'] = starCount;
      await prefs.setString(_starsKey, json.encode(stars));
    } catch (e) {
      print('Yıldız kaydetme hatası: $e');
    }
  }

  // Belirli bir stage-level için yıldız oku
  static Future<int> getStar(int stage, int level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final starsJson = prefs.getString(_starsKey);
      
      if (starsJson != null) {
        final stars = Map<String, int>.from(json.decode(starsJson));
        return stars['$stage-$level'] ?? 0;
      }
    } catch (e) {
      print('Yıldız okuma hatası: $e');
    }
    
    return 0;
  }

  // Tüm yıldızları oku
  static Future<Map<String, int>> getAllStars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final starsJson = prefs.getString(_starsKey);
      
      if (starsJson != null) {
        return Map<String, int>.from(json.decode(starsJson));
      }
    } catch (e) {
      print('Tüm yıldızları okuma hatası: $e');
    }
    
    return {};
  }

  // Hint sayısını güncelle
  static Future<void> updateHints(int newHintCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_hintsKey, newHintCount);
    } catch (e) {
      print('Hint güncelleme hatası: $e');
    }
  }

  // Hint sayısını oku
  static Future<int> getHints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_hintsKey) ?? 10;
    } catch (e) {
      print('Hint okuma hatası: $e');
    }
    
    return 10;
  }

  // Undo sayısını güncelle
  static Future<void> updateUndos(int newUndoCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_undosKey, newUndoCount);
    } catch (e) {
      print('Undo güncelleme hatası: $e');
    }
  }

  // Undo sayısını oku
  static Future<int> getUndos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_undosKey) ?? 5;
    } catch (e) {
      print('Undo okuma hatası: $e');
    }
    
    return 5;
  }

  // Tutorial görüldü olarak işaretle
  static Future<void> markTutorialAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tutorialSeenKey, true);
    } catch (e) {
      print('Tutorial işaretleme hatası: $e');
    }
  }

  // Tutorial görülüp görülmediğini kontrol et
  static Future<bool> isTutorialSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_tutorialSeenKey) ?? false;
    } catch (e) {
      print('Tutorial kontrol hatası: $e');
    }
    
    return false;
  }

  // Stage ve level ilerlemesini güncelle
  static Future<void> updateProgress(int stage, int level) async {
    try {
      final currentProgress = await loadProgress();
      final newProgress = UserProgress(
        openedStage: stage > currentProgress.openedStage ? stage : currentProgress.openedStage,
        openedLevel: level > currentProgress.openedLevel ? level : currentProgress.openedLevel,
        stars: currentProgress.stars,
        hints: currentProgress.hints,
        undos: currentProgress.undos,
        tutorialSeen: currentProgress.tutorialSeen,
      );
      
      await saveProgress(newProgress);
    } catch (e) {
      print('İlerleme güncelleme hatası: $e');
    }
  }
}