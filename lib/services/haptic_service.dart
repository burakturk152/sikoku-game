import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../l10n/app_localizations.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  DateTime? _lastVibrationTime;
  static const Duration _throttleDuration = Duration(milliseconds: 200); // Throttle süresini azalttık
  static const Duration _strongThrottleDuration = Duration(milliseconds: 100); // Güçlü titreşimler için daha kısa throttle

  /// Platform kontrolü
  bool get _isMobilePlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Debug modu - console'da titreşim bilgilerini göster
  bool _debugMode = true;

  /// Titreşim tetikle (platforma göre davranış)
  Future<void> vibrate({
    bool force = false,
    String event = 'vibration',
    BuildContext? context,
  }) async {
    final now = DateTime.now();
    
    // Throttle kontrolü (force true ise atla)
    if (!force && _lastVibrationTime != null) {
      final timeSinceLastVibration = now.difference(_lastVibrationTime!);
      if (timeSinceLastVibration < _throttleDuration) {
        if (_debugMode) print('🔇 Vibration throttled: $event (${timeSinceLastVibration.inMilliseconds}ms)');
        return; // Throttle - titreşim verme
      }
    }

    _lastVibrationTime = now;

    if (_debugMode) {
      print('📳 Triggering vibration: $event (Platform: ${_isMobilePlatform ? 'Mobile' : 'Desktop'})');
    }

    if (_isMobilePlatform) {
      // Android/iOS: Gerçek titreşim
      try {
        await HapticFeedback.lightImpact();
        if (_debugMode) print('✅ Light impact vibration sent');
      } catch (e) {
        print('❌ Haptic feedback error: $e');
      }
    } else {
      // Windows/macOS/Web/Emülatör: Görsel geri bildirim
      _showVisualFeedback(event, context);
      _logVibration(event);
    }
  }

  /// Güçlü titreşim (win durumu için)
  Future<void> vibrateStrong({
    bool force = false,
    String event = 'strong vibration',
    BuildContext? context,
  }) async {
    final now = DateTime.now();
    
    // Throttle kontrolü (güçlü titreşimler için daha kısa throttle)
    if (!force && _lastVibrationTime != null) {
      final timeSinceLastVibration = now.difference(_lastVibrationTime!);
      if (timeSinceLastVibration < _strongThrottleDuration) {
        if (_debugMode) print('🔇 Strong vibration throttled: $event (${timeSinceLastVibration.inMilliseconds}ms)');
        return;
      }
    }

    _lastVibrationTime = now;

    if (_debugMode) {
      print('💥 Triggering strong vibration: $event (Platform: ${_isMobilePlatform ? 'Mobile' : 'Desktop'})');
    }

    if (_isMobilePlatform) {
      // Android/iOS: Gerçek güçlü titreşim
      try {
        await HapticFeedback.mediumImpact();
        if (_debugMode) print('✅ Medium impact vibration sent');
      } catch (e) {
        print('❌ Strong haptic feedback error: $e');
      }
    } else {
      // Windows/macOS/Web/Emülatör: Görsel geri bildirim
      _showVisualFeedback(event, context);
      _logVibration(event);
    }
  }

  /// Görsel geri bildirim (mobil olmayan platformlar için)
  void _showVisualFeedback(String event, BuildContext? context) {
    if (context == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.vibrationTriggered(event)),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.blue.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Log yazdır (mobil olmayan platformlar için)
  void _logVibration(String event) {
    final timestamp = DateTime.now().toIso8601String();
    print('🔔 vibration: $event @ $timestamp');
  }

  /// Hata durumu için titreşim
  Future<void> vibrateError({
    bool force = false,
    String event = 'error vibration',
    BuildContext? context,
  }) async {
    final now = DateTime.now();
    
    if (!force && _lastVibrationTime != null) {
      final timeSinceLastVibration = now.difference(_lastVibrationTime!);
      if (timeSinceLastVibration < _throttleDuration) {
        if (_debugMode) print('🔇 Error vibration throttled: $event');
        return;
      }
    }

    _lastVibrationTime = now;

    if (_debugMode) {
      print('❌ Triggering error vibration: $event');
    }

    if (_isMobilePlatform) {
      try {
        await HapticFeedback.heavyImpact();
        if (_debugMode) print('✅ Heavy impact vibration sent');
      } catch (e) {
        print('❌ Error haptic feedback error: $e');
      }
    } else {
      _showVisualFeedback('HATA: $event', context);
      _logVibration(event);
    }
  }

  /// Başarı durumu için titreşim
  Future<void> vibrateSuccess({
    bool force = false,
    String event = 'success vibration',
    BuildContext? context,
  }) async {
    final now = DateTime.now();
    
    if (!force && _lastVibrationTime != null) {
      final timeSinceLastVibration = now.difference(_lastVibrationTime!);
      if (timeSinceLastVibration < _throttleDuration) {
        if (_debugMode) print('🔇 Success vibration throttled: $event');
        return;
      }
    }

    _lastVibrationTime = now;

    if (_debugMode) {
      print('🎉 Triggering success vibration: $event');
    }

    if (_isMobilePlatform) {
      try {
        await HapticFeedback.selectionClick();
        if (_debugMode) print('✅ Selection click vibration sent');
      } catch (e) {
        print('❌ Success haptic feedback error: $e');
      }
    } else {
      _showVisualFeedback('BAŞARI: $event', context);
      _logVibration(event);
    }
  }

  /// Test titreşimi - tüm türleri test etmek için
  Future<void> testAllVibrations({BuildContext? context}) async {
    if (_debugMode) {
      print('🧪 Testing all vibration types...');
    }

    await vibrate(event: 'Test - Light', context: context);
    await Future.delayed(Duration(milliseconds: 300));
    
    await vibrateStrong(event: 'Test - Strong', context: context);
    await Future.delayed(Duration(milliseconds: 300));
    
    await vibrateError(event: 'Test - Error', context: context);
    await Future.delayed(Duration(milliseconds: 300));
    
    await vibrateSuccess(event: 'Test - Success', context: context);
    
    if (_debugMode) {
      print('🧪 All vibration tests completed');
    }
  }

  /// Debug modunu aç/kapat
  void setDebugMode(bool enabled) {
    _debugMode = enabled;
    if (_debugMode) {
      print('🔧 HapticService debug mode: ON');
    }
  }

  /// Throttle'ı sıfırla (yeni ekran geçişlerinde)
  void resetThrottle() {
    _lastVibrationTime = null;
    if (_debugMode) {
      print('🔄 Vibration throttle reset');
    }
  }
}
