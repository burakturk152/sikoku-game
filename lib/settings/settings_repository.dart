import 'package:shared_preferences/shared_preferences.dart';
import 'settings_model.dart';

class SettingsRepository {
  static const String _prefsKey = 'app.settings.model';

  Future<SettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      final defaults = SettingsModel.defaults();
      await save(defaults);
      return defaults;
    }
    try {
      return SettingsModel.fromJsonString(raw);
    } catch (_) {
      final defaults = SettingsModel.defaults();
      await save(defaults);
      return defaults;
    }
  }

  Future<void> save(SettingsModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, model.toJsonString());
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    await save(SettingsModel.defaults());
  }
}
