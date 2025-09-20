import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../routes/app_router.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool isSoundOn = true;
  bool _animationCompleted = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final darkBlue = const Color(0xFF1A2233);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Arka planda büyük, silik logo
          Center(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/images/logo2.png',
                width: screenWidth * 0.85,
                height: screenHeight * 0.85,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06),
                // Neon başlık - AnimatedTextKit ile
                SizedBox(
                  height: screenHeight * 0.12,
                  child: _animationCompleted
                      ? Text(
                          'SIKOKU',
                          style: GoogleFonts.orbitron(
                            color: Colors.cyanAccent.shade100,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                            shadows: [
                              Shadow(color: Colors.cyanAccent.withOpacity(0.7), blurRadius: 18, offset: const Offset(0, 0)),
                              Shadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 0)),
                            ],
                          ),
                        )
                      : TextLiquidFill(
                          text: 'SIKOKU',
                          textStyle: GoogleFonts.orbitron(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                          ),
                          boxBackgroundColor: Colors.black,
                          boxHeight: screenHeight * 0.12,
                          loadDuration: const Duration(seconds: 3),
                          loadUntil: 1.0,
                          waveDuration: const Duration(seconds: 2),
                        ),
                ),
                const Spacer(),
                // Menü butonları
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MenuButton(
                      text: 'Oyna',
                      icon: Icons.play_arrow_rounded,
                      iconColor: Colors.lightBlueAccent,
                      backgroundColor: darkBlue,
                      onTap: () {
                        context.router.push(const MapRoute());
                      },
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.07,
                    ),
                    SizedBox(height: screenHeight * 0.018),
                    _MenuButton(
                      text: 'Ayarlar',
                      icon: Icons.settings_rounded,
                      iconColor: Colors.amber,
                      backgroundColor: darkBlue,
                      onTap: () {
                        context.router.push(const SettingsRoute());
                      },
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.07,
                    ),
                    SizedBox(height: screenHeight * 0.018),
                    _MenuButton(
                      text: 'Rehber',
                      icon: Icons.menu_book_rounded,
                      iconColor: Colors.orangeAccent,
                      backgroundColor: darkBlue,
                      onTap: () {
                        context.router.push(const GuideRoute());
                      },
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.07,
                    ),
                    SizedBox(height: screenHeight * 0.018),
                    _MenuButton(
                      text: 'Test Grid',
                      icon: Icons.grid_on_rounded,
                      iconColor: Colors.greenAccent,
                      backgroundColor: darkBlue,
                      onTap: () {
                        context.router.push(const TestGridLayout());
                      },
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.07,
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                // Alt ikonlar
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.04, left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.extension_rounded, color: Colors.white.withOpacity(0.7), size: screenHeight * 0.03),
                          SizedBox(width: screenWidth * 0.006),
                          Text(
                            'Başarılar',
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: screenHeight * 0.018,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: screenHeight * 0.035,
                        ),
                        onPressed: () => setState(() => isSoundOn = !isSoundOn),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: height * 0.55),
            SizedBox(width: screenWidth * 0.01),
            Text(
              text,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: height * 0.38,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 