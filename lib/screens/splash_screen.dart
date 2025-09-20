import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../routes/app_router.dart';
import '../services/user_progress_service.dart';
import '../services/image_cache_service.dart';
import '../audio/audio_gateway.dart';
import '../widgets/sikkoku_loading.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String _loadingStatus = 'Başlatılıyor...';

  @override
  void initState() {
    super.initState();
    _loadAssetsAndNavigate();
  }

  Future<void> _loadAssetsAndNavigate() async {
    try {
      // Progress verilerini yükle
      setState(() {
        _loadingStatus = 'İlerleme verileri yükleniyor...';
      });
      await Future.delayed(const Duration(seconds: 1));
      await UserProgressService.loadProgress();

      // Tüm önemli asset'leri precache et
      setState(() {
        _loadingStatus = 'Görseller yükleniyor...';
      });
      await Future.delayed(const Duration(seconds: 1));
      await _precacheAssets();
      
      // Ses dosyalarını yükle
      setState(() {
        _loadingStatus = 'Ses dosyaları yükleniyor...';
      });
      await Future.delayed(const Duration(seconds: 1));
      await _precacheAudioAssets();
      
      // Puzzle verilerini yükle
      setState(() {
        _loadingStatus = 'Oyun verileri hazırlanıyor...';
      });
      await Future.delayed(const Duration(seconds: 1));
      await _preloadPuzzleData();
      
      // Ekstra verileri yükle
      setState(() {
        _loadingStatus = 'Ekstra veriler yükleniyor...';
      });
      await Future.delayed(const Duration(seconds: 1));
      await _preloadExtraData();
      
      // Sistem hazırlığı
      setState(() {
        _loadingStatus = 'Sistem hazırlanıyor...';
      });
      await Future.delayed(const Duration(seconds: 1));
      await _initializeSystem();
      
      setState(() {
        _loadingStatus = 'Tamamlandı!';
      });
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 500));
        context.router.replace(MapRoute());
      }
    } catch (e) {
      print('Asset yükleme hatası: $e');
      setState(() {
        _loadingStatus = 'Hata oluştu, devam ediliyor...';
      });
      await Future.delayed(const Duration(seconds: 1));
      // Hata durumunda da devam et
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 500));
        context.router.replace(MapRoute());
      }
    }
  }

  Future<void> _precacheAssets() async {
    final List<String> imageAssets = [
      'assets/images/logo2.png',
      'assets/images/background-stage1.png',
      'assets/images/background-stage12.png',
      'assets/images/daily_button.png',
      'assets/images/market_button.png',
      'assets/images/profil_button.png',
      'assets/images/settings_button.png',
      'assets/images/weekly_button.png',
      'assets/images/weekly_butto1n.png',
      'assets/images/weekly_butto22n.png',
      'assets/images/earth.png',
      'assets/images/sunny.png',
      'assets/avatar/avatar1.png',
      'assets/avatar/avatar2.png',
      'assets/avatar/avatar3.png',
      'assets/avatar/avatar4.png',
      'assets/avatar/avatar5.png',
    ];

    // Tüm resimleri paralel olarak yükle
    await Future.wait(
      imageAssets.map((asset) => precacheImage(AssetImage(asset), context))
    );

    // Hint PNG'lerini özel olarak yükle (ui.Image formatında)
    await ImageCacheService().loadHintImages();
  }

  Future<void> _precacheAudioAssets() async {
    // Ses dosyalarını yükle (gerçek yükleme işlemi)
    try {
      // AudioGateway'i başlat
      final audioGateway = AudioGateway();
      
      // Ses dosyalarını önceden yükle - AssetBundle ile
      await DefaultAssetBundle.of(context).load('assets/audio/background_music_1.mp3');
      await DefaultAssetBundle.of(context).load('assets/audio/background_music_2.mp3');
      
      // AudioGateway'i hazırla
      await audioGateway.startBackgroundMusic();
    } catch (e) {
      print('Ses dosyası yükleme hatası: $e');
    }
  }

  Future<void> _preloadPuzzleData() async {
    // İlk 10 puzzle'ı önceden yükle
    try {
      for (int i = 1; i <= 10; i++) {
        await _loadPuzzleData(i);
      }
    } catch (e) {
      print('Puzzle verisi yükleme hatası: $e');
    }
  }

  Future<void> _loadPuzzleData(int level) async {
    // Puzzle verilerini yükle - Evren 1 için
    try {
      final String assetPath = 'assets/data/stage1/level_$level.json';
      await DefaultAssetBundle.of(context).loadString(assetPath);
    } catch (e) {
      print('Level $level yükleme hatası: $e');
    }
  }

  Future<void> _preloadExtraData() async {
    // Daily ve Weekly puzzle'ları yükle
    try {
      // Daily puzzle
      await DefaultAssetBundle.of(context).loadString('assets/daily/puzzle_2025-08-09.json');
      
      // Weekly puzzle
      await DefaultAssetBundle.of(context).loadString('assets/weekly/puzzle_2025-08-04.json');
      
      // Ekstra puzzle'ları da yükle (11-20 arası)
      for (int i = 11; i <= 20; i++) {
        await _loadPuzzleData(i);
      }
    } catch (e) {
      print('Ekstra veri yükleme hatası: $e');
    }
  }

  Future<void> _initializeSystem() async {
    // Sistem başlatma işlemleri
    try {
      // SharedPreferences'ı başlat
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Cache temizleme ve optimizasyon
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Sistem hazırlığı
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      print('Sistem başlatma hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12), // Siyah arka plan
      body: Stack(
        children: [
          // Ana içerik - başlık ve loading widget
          Center(
            child: Column(
              children: [
                // Boşluk - üstte
                SizedBox(height: screenHeight * 0.25),
                
                // Sikoku Tango Puzzle başlığı
                Text(
                  'Sikoku Tango Puzzle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.cyanAccent.shade100,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.cyanAccent.withOpacity(0.7),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                // Loading widget - orta boyut
                SikkokuLoading(size: 240),
                
                // Yükleme yazısı - animasyon ile arası açık
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.05),
                    child: Text(
                      _loadingStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.cyanAccent.shade100,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
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