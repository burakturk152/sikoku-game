import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'inventory_model.dart';

class InventoryRepository {
  static const String _key = 'inventory_v1';

  Future<InventoryModel> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          return InventoryModel.fromJson(json);
        } catch (parseError) {
          print('Error parsing inventory JSON: $parseError');
          // Eski veri formatı varsa sil ve defaults döndür
          await prefs.remove(_key);
          return InventoryModel.defaults();
        }
      }
      
      // İlk kez yükleniyorsa defaults kaydet
      final defaults = InventoryModel.defaults();
      await save(defaults);
      return defaults;
    } catch (e) {
      print('Error loading inventory: $e');
      return InventoryModel.defaults();
    }
  }

  Future<void> save(InventoryModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(model.toJson());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      print('Error saving inventory: $e');
    }
  }

  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error resetting inventory: $e');
    }
  }
}
