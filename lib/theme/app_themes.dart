import 'package:flutter/material.dart';

// AppPalette sınıfı - tema renkleri için
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bottomBarBackground;
  final Color bottomBarIcon;
  final Color bottomBarText;
  final Color puzzleBackground;
  final Color counterTextColor;
  final Gradient earthCellGradient;
  final Gradient sunCellGradient;
  final Color emptyCellColor;

  const AppPalette({
    required this.bottomBarBackground,
    required this.bottomBarIcon,
    required this.bottomBarText,
    required this.puzzleBackground,
    required this.counterTextColor,
    required this.earthCellGradient,
    required this.sunCellGradient,
    required this.emptyCellColor,
  });

  // Açık tema renkleri
  static const AppPalette light = AppPalette(
    bottomBarBackground: Color(0xB3FFFFFF), // Colors.white.withOpacity(0.70)
    bottomBarIcon: Color(0xDE000000), // Colors.black87
    bottomBarText: Color(0xDE000000), // Colors.black87
    puzzleBackground: Color(0xFFF3F4F6), // Açık gri
    counterTextColor: Color(0xDE000000), // Colors.black87
    earthCellGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7FBCE9), // daha kontrastlı pastel mavi
        Color(0xFF6BA8D4), // biraz daha koyu ton
      ],
    ),
    sunCellGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFD966), // daha canlı pastel sarı
        Color(0xFFFFC233), // biraz daha koyu ton
      ],
    ),
    emptyCellColor: Color(0xFF54636B), // mevcut griye yakın
  );

  // Koyu tema renkleri
  static const AppPalette dark = AppPalette(
    bottomBarBackground: Color(0x99000000), // Colors.black.withOpacity(0.60)
    bottomBarIcon: Colors.white,
    bottomBarText: Colors.white,
    puzzleBackground: Colors.black,
    counterTextColor: Colors.white,
    earthCellGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7FBCE9), // daha kontrastlı pastel mavi
        Color(0xFF6BA8D4), // biraz daha koyu ton
      ],
    ),
    sunCellGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFD966), // daha canlı pastel sarı
        Color(0xFFFFC233), // biraz daha koyu ton
      ],
    ),
    emptyCellColor: Color(0xFF54636B), // mevcut griye yakın
  );

  @override
  AppPalette copyWith({
    Color? bottomBarBackground,
    Color? bottomBarIcon,
    Color? bottomBarText,
    Color? puzzleBackground,
    Color? counterTextColor,
    Gradient? earthCellGradient,
    Gradient? sunCellGradient,
    Color? emptyCellColor,
  }) {
    return AppPalette(
      bottomBarBackground: bottomBarBackground ?? this.bottomBarBackground,
      bottomBarIcon: bottomBarIcon ?? this.bottomBarIcon,
      bottomBarText: bottomBarText ?? this.bottomBarText,
      puzzleBackground: puzzleBackground ?? this.puzzleBackground,
      counterTextColor: counterTextColor ?? this.counterTextColor,
      earthCellGradient: earthCellGradient ?? this.earthCellGradient,
      sunCellGradient: sunCellGradient ?? this.sunCellGradient,
      emptyCellColor: emptyCellColor ?? this.emptyCellColor,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }
    return AppPalette(
      bottomBarBackground: Color.lerp(bottomBarBackground, other.bottomBarBackground, t)!,
      bottomBarIcon: Color.lerp(bottomBarIcon, other.bottomBarIcon, t)!,
      bottomBarText: Color.lerp(bottomBarText, other.bottomBarText, t)!,
      puzzleBackground: Color.lerp(puzzleBackground, other.puzzleBackground, t)!,
      counterTextColor: Color.lerp(counterTextColor, other.counterTextColor, t)!,
      earthCellGradient: earthCellGradient, // Gradient lerp desteklenmiyor, sabit tutuyoruz
      sunCellGradient: sunCellGradient, // Gradient lerp desteklenmiyor, sabit tutuyoruz
      emptyCellColor: Color.lerp(emptyCellColor, other.emptyCellColor, t)!,
    );
  }
}

// Tema yapılandırması
class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
      scaffoldBackgroundColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      brightness: Brightness.light,
      extensions: const [AppPalette.light],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      scaffoldBackgroundColor: Colors.black,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      brightness: Brightness.dark,
      extensions: const [AppPalette.dark],
    );
  }
}