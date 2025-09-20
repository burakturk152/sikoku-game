import 'package:shared_preferences/shared_preferences.dart';

class AdminModeRepository {
  static const String _key = 'admin_mode_v1';

  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
