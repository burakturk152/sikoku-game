import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Keys
  static const String kMusicEnabled = 'settings.musicEnabled';
  static const String kSfxEnabled = 'settings.sfxEnabled';
  static const String kMasterVolume = 'settings.masterVolume'; // int 0-100
  static const String kHaptics = 'settings.haptics';
  static const String kNotifyDaily = 'settings.notifyDaily';
  static const String kNotifyWeekly = 'settings.notifyWeekly';
  static const String kLocale = 'settings.locale'; // 'tr' | 'en'

  // Profile keys for reset
  static const String kProfileAvatarPath = 'profile.avatarPath';
  static const String kProfileUsername = 'profile.username';

  // Defaults
  static const bool defaultMusicEnabled = true;
  static const bool defaultSfxEnabled = true;
  static const int defaultMasterVolume = 70;
  static const bool defaultHaptics = true;
  static const bool defaultNotifyDaily = true;
  static const bool defaultNotifyWeekly = true;
  static const String defaultLocale = 'tr';

  static Future<Map<String, Object>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    return <String, Object>{
      kMusicEnabled: prefs.getBool(kMusicEnabled) ?? defaultMusicEnabled,
      kSfxEnabled: prefs.getBool(kSfxEnabled) ?? defaultSfxEnabled,
      kMasterVolume: prefs.getInt(kMasterVolume) ?? defaultMasterVolume,
      kHaptics: prefs.getBool(kHaptics) ?? defaultHaptics,
      kNotifyDaily: prefs.getBool(kNotifyDaily) ?? defaultNotifyDaily,
      kNotifyWeekly: prefs.getBool(kNotifyWeekly) ?? defaultNotifyWeekly,
      kLocale: prefs.getString(kLocale) ?? defaultLocale,
    };
  }

  static Future<void> setMusicEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kMusicEnabled, value);
  }

  static Future<void> setSfxEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kSfxEnabled, value);
  }

  static Future<void> setMasterVolume(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kMasterVolume, value.clamp(0, 100));
  }

  static Future<void> setHaptics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kHaptics, value);
  }

  static Future<void> setNotifyDaily(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotifyDaily, value);
  }

  static Future<void> setNotifyWeekly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotifyWeekly, value);
  }

  static Future<void> setLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLocale, (code == 'en') ? 'en' : 'tr');
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kMusicEnabled);
    await prefs.remove(kSfxEnabled);
    await prefs.remove(kMasterVolume);
    await prefs.remove(kHaptics);
    await prefs.remove(kNotifyDaily);
    await prefs.remove(kNotifyWeekly);
    await prefs.remove(kLocale);
    await prefs.remove(kProfileAvatarPath);
    await prefs.remove(kProfileUsername);
  }
}


