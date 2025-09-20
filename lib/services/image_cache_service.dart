import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  ui.Image? _equalImage;
  ui.Image? _notEqualImage;
  bool _isLoaded = false;

  ui.Image? get equalImage => _equalImage;
  ui.Image? get notEqualImage => _notEqualImage;
  bool get isLoaded => _isLoaded;

  Future<void> loadHintImages() async {
    if (_isLoaded) return;

    try {
      // Equal image yükle
      final equalCodec = await ui.instantiateImageCodec(
        (await rootBundle.load('assets/images/equal.png')).buffer.asUint8List(),
      );
      final equalFrame = await equalCodec.getNextFrame();
      _equalImage = equalFrame.image;

      // Not equal image yükle
      final notEqualCodec = await ui.instantiateImageCodec(
        (await rootBundle.load('assets/images/notequal.png')).buffer.asUint8List(),
      );
      final notEqualFrame = await notEqualCodec.getNextFrame();
      _notEqualImage = notEqualFrame.image;

      _isLoaded = true;
    } catch (e) {
      print('Error loading hint images: $e');
    }
  }

  void clearCache() {
    _equalImage = null;
    _notEqualImage = null;
    _isLoaded = false;
  }
}
