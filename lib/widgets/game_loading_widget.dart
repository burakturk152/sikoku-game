import 'package:flutter/material.dart';

class GameLoadingWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const GameLoadingWidget({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Boşluk - üstte
          SizedBox(height: screenHeight * 0.1),
          
          // Oyun adı
          Text(
            'SIKOKU',
            style: TextStyle(
              color: Colors.cyanAccent.shade100,
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              shadows: [
                Shadow(color: Colors.cyanAccent.withOpacity(0.7), blurRadius: 18, offset: const Offset(0, 0)),
                Shadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 0)),
              ],
            ),
          ),
          
          SizedBox(height: screenHeight * 0.08),
          
          // Loading indicator
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: screenHeight * 0.025),
          Text(
            'Bulmaca yükleniyor...',
            style: TextStyle(
              color: Colors.white, 
              fontSize: screenWidth * 0.015
            ),
          ),
        ],
      ),
    );
  }
} 