import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class UniverseData {
  final String backgroundImage;
  final String name;
  final String theme;
  final int maxLevels;
  final bool isUnlocked;
  final String description;
  final String cellImage1; // state == 1 için görsel
  final String cellImage2; // state == 2 için görsel

  const UniverseData({
    required this.backgroundImage,
    required this.name,
    required this.theme,
    required this.maxLevels,
    required this.isUnlocked,
    required this.description,
    required this.cellImage1,
    required this.cellImage2,
  });
}

class UniverseConfig {
  static Map<int, UniverseData> getUniverses(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return {
      1: UniverseData(
        backgroundImage: 'assets/images/background-stage1.png',
        name: l10n.spaceUniverse,
        theme: 'space',
        maxLevels: 50,
        isUnlocked: true, // İlk evren her zaman açık
        description: l10n.spaceUniverseDescription,
        cellImage1: 'assets/images/earth.png', // Mavi hücreler için
        cellImage2: 'assets/images/sunny.png', // Sarı hücreler için
      ),
      2: UniverseData(
        backgroundImage: 'assets/images/background-stage2.png',
        name: l10n.forestUniverse,
        theme: 'forest',
        maxLevels: 50,
        isUnlocked: false, // Evren 1 tamamlandığında açılacak
        description: l10n.forestUniverseDescription,
        cellImage1: 'assets/images/blueberry.png', // Mavi hücreler için
        cellImage2: 'assets/images/banana.png', // Sarı hücreler için
      ),
    };
  }

  // Mevcut evreni getir
  static UniverseData getUniverse(int universeId, BuildContext context) {
    final universes = getUniverses(context);
    return universes[universeId] ?? universes[1]!;
  }

  // Tüm evrenleri getir
  static List<UniverseData> getAllUniverses(BuildContext context) {
    return getUniverses(context).values.toList();
  }

  // Evren kilidini kontrol et
  static bool isUniverseUnlocked(int universeId, BuildContext context) {
    final universes = getUniverses(context);
    return universes[universeId]?.isUnlocked ?? false;
  }

  // Evren kilidini aç
  static Future<void> unlockUniverse(int universeId) async {
    // SharedPreferences ile evren kilidini aç
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('universe_${universeId}_unlocked', true);
  }

  // Evren kilidini kapat
  static Future<void> lockUniverse(int universeId) async {
    // SharedPreferences ile evren kilidini kapat
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('universe_${universeId}_unlocked', false);
  }

  // Evren kilidini kontrol et (SharedPreferences'tan)
  static Future<bool> isUniverseUnlockedFromPrefs(int universeId) async {
    if (universeId == 1) return true; // İlk evren her zaman açık
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('universe_${universeId}_unlocked') ?? false;
  }

  // Evren sayısını getir
  static int getUniverseCount() {
    return 2; // Sabit sayı
  }
}
