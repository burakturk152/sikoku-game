import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleRepository {
  static const String _key = 'app_locale_v1';

  Future<Locale?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString(_key);
    
    if (localeString == null) return null;
    
    // "tr_TR" -> Locale('tr', 'TR')
    final parts = localeString.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    
    return null;
  }

  Future<void> save(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = '${locale.languageCode}_${locale.countryCode}';
    await prefs.setString(_key, localeString);
  }
}
