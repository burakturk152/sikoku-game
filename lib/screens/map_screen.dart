import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../routes/app_router.dart';
import '../widgets/level_path_layout.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/bottom_nav_item.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import '../services/weekly_puzzle_selection.dart';
import 'package:flutter/services.dart';
import '../bloc/level_progress_cubit.dart';
import '../bloc/game_stats_cubit.dart';
import '../services/daily_puzzle_selection.dart';
import '../inventory/inventory_cubit.dart';
import '../inventory/inventory_state.dart';
import '../admin/admin_mode_cubit.dart';
import '../bloc/profile_cubit.dart';
import '../l10n/app_localizations.dart';
import '../config/universe_config.dart';
import '../widgets/universe_selector.dart';

@RoutePage()
class MapScreen extends StatefulWidget {
  final int stage;
  const MapScreen({Key? key, this.stage = 1}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final int totalLevels = 50;
  bool _isRefreshing = false;
  int _refreshKey = 0;
  late ScrollController scrollController; // Scroll controller
  // _currentUniverseId artık GameStatsCubit'ten alınıyor

  // Illustrator SVG bilgileri - tek doğruluk kaynağı
  static const Size _viewBox = Size(750, 1334);
  static const String _polylinePoints = '''
447.25 1331.27 451.79 1318.42 454.44 1298.77 454.44 1279.87 450.85 1264.37 441.59 1246.61 432.52 1235.65 418.54 1222.80 407.96 1214.86 389.44 1204.66 365.25 1192.94 349.00 1185.38 316.50 1171.77 290.80 1158.54 272.28 1148.34 256.78 1137.76 241.28 1123.78 224.65 1106.77 217.47 1096.19 214.82 1086.00 212.93 1068.61 215.20 1053.49 217.47 1044.80 222.76 1032.71 231.07 1018.73 243.92 1005.50 260.17 994.16 286.25 980.18 309.68 970.73 339.92 958.64 360.33 948.44 376.58 939.37 390.19 927.28 399.26 914.43 405.31 898.56 404.55 880.80 402.66 867.19 392.46 845.65 384.52 827.89 373.94 810.88 364.11 791.60 352.02 768.17 347.86 748.52 345.97 727.73 347.86 706.19 355.80 683.13 364.49 663.48 380.74 644.20 396.24 625.68 412.87 608.67 443.11 581.84 480.91 548.96 511.90 522.13 536.09 499.45 551.21 482.44 562.55 466.57 568.60 449.18 571.62 431.79 567.46 412.14 561.41 397.40 554.61 385.31 540.63 368.68 529.29 356.21 508.12 330.13 496.78 312.74 487.71 291.95 484.69 279.86 486.96 262.10 501.32 230.35 515.68 207.67 527.77 181.21 537.60 154.38 538.73 127.17 534.19 110.54 528.90 93.91 512.65 76.15 497.15 62.17 471.07 41.38 453.31 27.40 445.00 16.06 444.24 0.09
''';

  @override
  void initState() {
    super.initState();
    _initializeAndLoadProgress();
    
    // Scroll controller'ı initState'de oluştur
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoadProgress() async {
    // Oyun başladığında progress'i yükle
    final gameStatsCubit = context.read<GameStatsCubit>();
    final currentStats = gameStatsCubit.state;
    
    // Universe 2 kilidi artık test amaçlı kapatılmıyor
    // Universe 2 kilidi level 50 tamamlandığında otomatik açılacak
    
    // Eğer hiç veri yoksa sadece Level 1'i aç
    if (currentStats.unlockedLevels.isEmpty) {
      print('=== INITIALIZING PROGRESS - ONLY LEVEL 1 UNLOCKED ===');
      await gameStatsCubit.resetStats(); // Sadece Level 1 açık
      print('=== PROGRESS INITIALIZED ===');
    } else {
      print('=== LOADING EXISTING PROGRESS ===');
      print('Unlocked Levels: ${currentStats.unlockedLevels}');
      print('Total Stars: ${currentStats.totalStars}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // İlk kez build edildiğinde scroll pozisyonunu ayarla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && scrollController.offset == 0) {
        scrollController.jumpTo(4 * screenHeight); // En alttaki resim görünsün
      }
    });
    
    return BlocBuilder<GameStatsCubit, GameStatsState>(
      builder: (context, gameStatsState) {
        return BlocBuilder<LevelProgressCubit, LevelProgressState>(
          builder: (context, levelProgressState) {
            return Scaffold(
              body: GestureDetector(
                onPanUpdate: (details) {
                  // Manuel scroll kontrolü
                  final delta = details.delta.dy;
                  final currentOffset = scrollController.offset;
                  final newOffset = (currentOffset - delta).clamp(0.0, screenHeight * 4);
                  scrollController.jumpTo(newOffset);
                },
                child: Stack(
                  children: [
                    // 1. Scroll edilebilir arka plan resimleri
                    SingleChildScrollView(
                      controller: scrollController, // Controller eklendi
                      physics: const NeverScrollableScrollPhysics(), // Otomatik scroll'u kapat
                      child: SizedBox(
                        height: screenHeight * 5, // 5 kez yükseklik
                        child: Stack(
                          children: [
                            // Arka plan resimleri - Evren sistemine göre
                            BlocBuilder<GameStatsCubit, GameStatsState>(
                              builder: (context, gameStatsState) {
                                final currentUniverse = UniverseConfig.getUniverse(gameStatsState.currentUniverseId, context);
                                return Stack(
                                  children: List.generate(5, (i) {
                                    return Positioned(
                                      top: (4 - i) * screenHeight, // En alttaki resim 0, yukarı doğru 1,2,3,4
                                      left: 0,
                                      right: 0,
                                      height: screenHeight,
                                      child: Image.asset(
                                        currentUniverse.backgroundImage,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                            
                            // Level butonları - Tüm segmentlerde (50 level)
                            
                            // Segment 0 (en altta) - Boşluk var
                            Positioned(
                              top: 4 * screenHeight,
                              left: 0,
                              right: 0,
                              height: screenHeight,
                              child: _PathBasedLevelLayout(
                                polylinePoints: _polylinePoints,
                                viewBoxSize: _viewBox,
                                screenSize: Size(screenWidth, screenHeight),
                                levelCount: 10, // Her segmentte 10 level
                                startOffsetRatio: 0.15, // Boşluk var
                                endOffsetRatio: 0.0,
                                buttonSize: 35,
                                debugShowPath: false,
                                debugShowCoverArea: false,
                                unlockedLevels: gameStatsState.unlockedLevels,
                                levelStars: levelProgressState.levelStars,
                                onLevelTap: _startLevel,
                                levelStart: 1, // Level 1-10
                              ),
                            ),
                            
                            // Segment 1 - Boşluk yok
                            Positioned(
                              top: 3 * screenHeight,
                              left: 0,
                              right: 0,
                              height: screenHeight,
                              child: _PathBasedLevelLayout(
                                polylinePoints: _polylinePoints,
                                viewBoxSize: _viewBox,
                                screenSize: Size(screenWidth, screenHeight),
                                levelCount: 10,
                                startOffsetRatio: 0.0, // Boşluk yok
                                endOffsetRatio: 0.0,
                                buttonSize: 35,
                                debugShowPath: false,
                                debugShowCoverArea: false,
                                unlockedLevels: gameStatsState.unlockedLevels,
                                levelStars: levelProgressState.levelStars,
                                onLevelTap: _startLevel,
                                levelStart: 11, // Level 11-20
                              ),
                            ),
                            
                            // Segment 2 - Boşluk yok
                            Positioned(
                              top: 2 * screenHeight,
                              left: 0,
                              right: 0,
                              height: screenHeight,
                              child: _PathBasedLevelLayout(
                                polylinePoints: _polylinePoints,
                                viewBoxSize: _viewBox,
                                screenSize: Size(screenWidth, screenHeight),
                                levelCount: 10,
                                startOffsetRatio: 0.0, // Boşluk yok
                                endOffsetRatio: 0.0,
                                buttonSize: 35,
                                debugShowPath: false,
                                debugShowCoverArea: false,
                                unlockedLevels: gameStatsState.unlockedLevels,
                                levelStars: levelProgressState.levelStars,
                                onLevelTap: _startLevel,
                                levelStart: 21, // Level 21-30
                              ),
                            ),
                            
                            // Segment 3 - Boşluk yok
                            Positioned(
                              top: 1 * screenHeight,
                              left: 0,
                              right: 0,
                              height: screenHeight,
                              child: _PathBasedLevelLayout(
                                polylinePoints: _polylinePoints,
                                viewBoxSize: _viewBox,
                                screenSize: Size(screenWidth, screenHeight),
                                levelCount: 10,
                                startOffsetRatio: 0.0, // Boşluk yok
                                endOffsetRatio: 0.0,
                                buttonSize: 35,
                                debugShowPath: false,
                                debugShowCoverArea: false,
                                unlockedLevels: gameStatsState.unlockedLevels,
                                levelStars: levelProgressState.levelStars,
                                onLevelTap: _startLevel,
                                levelStart: 31, // Level 31-40
                              ),
                            ),
                            
                            // Segment 4 (en üstte) - Boşluk var
                            Positioned(
                              top: 0 * screenHeight,
                              left: 0,
                              right: 0,
                              height: screenHeight,
                              child: _PathBasedLevelLayout(
                                polylinePoints: _polylinePoints,
                                viewBoxSize: _viewBox,
                                screenSize: Size(screenWidth, screenHeight),
                                levelCount: 10,
                                startOffsetRatio: 0.0, // Boşluk yok
                                endOffsetRatio: 0.12, // %12 boşluk
                                buttonSize: 35,
                                debugShowPath: false,
                                debugShowCoverArea: false,
                                unlockedLevels: gameStatsState.unlockedLevels,
                                levelStars: levelProgressState.levelStars,
                                onLevelTap: _startLevel,
                                levelStart: 41, // Level 41-50
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                  // 3. Üst başlık - Envanter bilgileri (sabit pozisyonda)
                  Positioned(
                    top: screenHeight * 0.02, // Ekranın üstünde sabit
                    left: screenWidth * 0.04,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oyuncu',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          BlocBuilder<InventoryCubit, InventoryState>(
                            builder: (context, inventoryState) {
                              final model = inventoryState.model;
                              final isAdmin = context.watch<AdminModeCubit>().state;
                              
                              return Row(
                                children: [
                                  _StatChip(
                                    icon: Icons.lightbulb,
                                    label: l10n.hint,
                                    value: isAdmin ? '∞' : '${model.hintCount}',
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    icon: Icons.undo,
                                    label: l10n.undo,
                                    value: isAdmin ? '∞' : '${model.undoCount}',
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    icon: Icons.check,
                                    label: l10n.control,
                                    value: isAdmin ? '∞' : '${model.checkCount}',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Evren seçici buton - Sağ üst köşe
                  Positioned(
                    top: screenHeight * 0.02,
                    right: screenWidth * 0.04,
                    child: _UniverseSelectorButton(
                      currentUniverseId: context.read<GameStatsCubit>().state.currentUniverseId,
                      onTap: _openUniverseSelector,
                    ),
                  ),

                  // 5. Otomatik tamamlama butonu - Sadece Evren 1'de, yukarıdan ortalı sola yaslı
                  if (context.read<GameStatsCubit>().state.currentUniverseId == 1)
                    Positioned(
                      top: screenHeight * 0.02,
                      left: screenWidth * 0.04,
                      child: _AutoCompleteButton(
                        onTap: _autoCompleteLevels,
                      ),
                    ),

                  // 6. Alt navigasyon barı - Sabit pozisyonda
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0, // Ekranın altında sabit
                    child: MapBottomBar(
                      onTapDaily: () => _openDailyCalendar(),
                      onTapWeekly: () => _openWeekly(),
                      onTapProfile: () => context.router.push(const ProfileRoute()),
                      onTapSettings: () => context.router.push(const SettingsRoute()),
                      onTapMarket: () => context.router.push(const StoreRoute()),
                    ),
                  ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startLevel(int level) {
    // Mevcut evren ID'sini GameStatsCubit'ten al
    final gameStatsCubit = context.read<GameStatsCubit>();
    final currentUniverseId = gameStatsCubit.state.currentUniverseId;
    print('=== START LEVEL DEBUG ===');
    print('Current Universe ID: $currentUniverseId');
    print('Level: $level');
    print('Stage parameter: $currentUniverseId');
    print('=== END DEBUG ===');
    context.router.push(GameRoute(stage: currentUniverseId, level: level));
  }

  void _openUniverseSelector() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => UniverseSelector(
        currentUniverseId: context.read<GameStatsCubit>().state.currentUniverseId,
        onUniverseSelected: (universeId) async {
          final currentUniverseId = context.read<GameStatsCubit>().state.currentUniverseId;
          if (universeId != currentUniverseId) {
            // Evren değiştirildi, progress'i güncelle
            final gameStatsCubit = context.read<GameStatsCubit>();
            final levelProgressCubit = context.read<LevelProgressCubit>();
            
            await gameStatsCubit.switchUniverse(universeId);
            await levelProgressCubit.switchUniverse(universeId);
            
            setState(() {
              // _currentUniverseId artık GameStatsCubit'te yönetiliyor
            });
          }
        },
      ),
    );
  }

  void _autoCompleteLevels() async {
    // Onay dialogu göster
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Otomatik Tamamlama',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'İlk 49 bölümü 3 yıldızla otomatik tamamlamak istediğinizden emin misiniz?',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Tamamla',
              style: GoogleFonts.poppins(color: Colors.blue),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Loading göster
      EasyLoading.show(status: 'Bölümler tamamlanıyor...');
      
      try {
        final gameStatsCubit = context.read<GameStatsCubit>();
        final levelProgressCubit = context.read<LevelProgressCubit>();
        
        // İlk 49 bölümü 3 yıldızla tamamla (50. bölümü dahil etme)
        for (int level = 1; level <= 49; level++) {
          // Level'i aç
          await levelProgressCubit.unlockLevel(level);
          // 3 yıldız ver
          await levelProgressCubit.updateStars(level, 3);
          // Level'i tamamla (0 saniye)
          await gameStatsCubit.onLevelCompleted(level, 0);
        }
        
        // 50. bölümü sadece aç (yıldız verme, tamamlama)
        await levelProgressCubit.unlockLevel(50);
        
        EasyLoading.dismiss();
        
        // Başarı mesajı
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.levelsCompletedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        EasyLoading.dismiss();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _UniverseSelectorButton extends StatelessWidget {
  final int currentUniverseId;
  final VoidCallback onTap;

  const _UniverseSelectorButton({
    required this.currentUniverseId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentUniverse = UniverseConfig.getUniverse(currentUniverseId, context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.public,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              currentUniverse.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoCompleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AutoCompleteButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Hızlı Tamamla',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyPuzzleButton extends StatelessWidget {
  final VoidCallback onTap;
  final double? sizeOverride;
  const _DailyPuzzleButton({required this.onTap, this.sizeOverride});

  @override
  Widget build(BuildContext context) {
    final Size mqSize = MediaQuery.of(context).size;
    // Güncel boyut kuralı: min 40, max 80, oran 0.12 (override varsa onu kullan)
    final double fallbackSize = (mqSize.width * 0.12).clamp(40.0, 80.0).toDouble();
    final double iconSize = sizeOverride ?? fallbackSize;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: iconSize,
        height: iconSize,
        child: Image.asset(
          'assets/images/daily_button.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

extension on _MapScreenState {
  Future<void> _openDailyCalendar() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final maxWidth = size.width * 0.7; // Ekranın %70'i
        final maxHeight = size.height * 0.56; // Ekranın %56'sı
        final dialogWidth = maxWidth > 450 ? 450.0 : maxWidth;
        final dialogHeight = maxHeight > 500 ? 500.0 : maxHeight;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: _DailyCalendar(
                focusedDay: today,
                onSelectToday: () {
                  Navigator.of(context).pop();
                  _startDaily(today);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _startDaily(DateTime date) {
    // Route args günlük tarihi henüz desteklemiyor; geçici olarak bir servis ile aktar
    DailyPuzzleSelection.set(date);
    context.router.push(GameRoute(stage: widget.stage, level: 1));
  }

  Future<void> _openWeekly() async {
    try {
      EasyLoading.show(status: 'Yükleniyor...');
      final now = DateTime.now();
      final int weekday = now.weekday; // 1=Mon ... 7=Sun
      final DateTime monday = now.subtract(Duration(days: weekday - 1));
      
      // Haftalık puzzle seçimini set et
      WeeklyPuzzleSelection.set(monday);
      
      EasyLoading.dismiss();
      context.router.push(GameRoute(stage: widget.stage, level: 1));
    } catch (e) {
      EasyLoading.dismiss();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Haftalık bulmaca bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _DailyCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onSelectToday;

  const _DailyCalendar({
    required this.focusedDay,
    required this.onSelectToday,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = focusedDay.subtract(const Duration(days: 365));
    final lastDay = focusedDay.add(const Duration(days: 365));
    final theme = Theme.of(context);

    return TableCalendar<void>(
      locale: 'tr_TR',
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: focusedDay,
      availableGestures: AvailableGestures.none,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: theme.textTheme.titleMedium!.copyWith(color: Colors.white),
        leftChevronVisible: false,
        rightChevronVisible: false,
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: TextStyle(color: Colors.white70),
        weekendTextStyle: TextStyle(color: Colors.white70),
        disabledTextStyle: TextStyle(color: Colors.white24),
        todayTextStyle: TextStyle(color: Colors.black),
        todayDecoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
        selectedTextStyle: TextStyle(color: Colors.black),
        selectedDecoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
      ),
      calendarBuilders: CalendarBuilders(
        disabledBuilder: (context, day, _) {
          return Center(
            child: Text('${day.day}', style: const TextStyle(color: Colors.white24)),
          );
        },
        defaultBuilder: (context, day, _) {
          final isToday = _isSameDay(day, focusedDay);
          if (isToday) {
            return Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${day.day}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            );
          }
          return Center(
            child: Text('${day.day}', style: const TextStyle(color: Colors.white24)),
          );
        },
      ),
      enabledDayPredicate: (day) => _isSameDay(day, focusedDay),
      onDaySelected: (selectedDay, _) {
        if (_isSameDay(selectedDay, focusedDay)) {
          onSelectToday();
        }
      },
      selectedDayPredicate: (day) => _isSameDay(day, focusedDay),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _PathBasedLevelLayout extends StatelessWidget {
  final String polylinePoints;
  final Size viewBoxSize;
  final Size screenSize;
  final int levelCount;
  final double startOffsetRatio;
  final double endOffsetRatio;
  final double buttonSize;
  final bool debugShowPath;
  final bool debugShowCoverArea;
  final List<int> unlockedLevels;
  final Map<int, int> levelStars;
  final void Function(int levelIndex) onLevelTap;
  final int levelStart; // Level numaralarının başlangıç değeri

  const _PathBasedLevelLayout({
    required this.polylinePoints,
    required this.viewBoxSize,
    required this.screenSize,
    required this.levelCount,
    required this.startOffsetRatio,
    required this.endOffsetRatio,
    required this.buttonSize,
    required this.debugShowPath,
    required this.debugShowCoverArea,
    required this.unlockedLevels,
    required this.levelStars,
    required this.onLevelTap,
    required this.levelStart,
  });

  // SVG polyline "points" string'ini parse et
  List<Offset> _parsePolylinePoints(String raw) {
    final tokens = raw.trim().split(RegExp(r'[\s,]+')).where((t) => t.isNotEmpty);
    final nums = <double>[];
    for (var t in tokens) {
      if (t.startsWith('.')) t = '0$t';
      if (t.startsWith('-.')) t = t.replaceFirst('-.', '-0.');
      nums.add(double.parse(t));
    }
    final points = <Offset>[];
    for (int i = 0; i + 1 < nums.length; i += 2) {
      points.add(Offset(nums[i], nums[i + 1]));
    }
    return points;
  }

  // BoxFit.cover dönüşümü hesapla (arka plan ile aynı)
  _CoverTransform _calculateCoverTransform() {
    final sourceAspect = viewBoxSize.width / viewBoxSize.height;
    final targetAspect = screenSize.width / screenSize.height;
    
    double scaleX, scaleY, offsetX, offsetY;
    
    if (sourceAspect > targetAspect) {
      // Kaynak daha geniş - yüksekliğe göre ölçekle
      scaleY = screenSize.height / viewBoxSize.height;
      scaleX = scaleY;
      offsetX = (screenSize.width - viewBoxSize.width * scaleX) / 2;
      offsetY = 0;
    } else {
      // Kaynak daha yüksek - genişliğe göre ölçekle
      scaleX = screenSize.width / viewBoxSize.width;
      scaleY = scaleX;
      offsetX = 0;
      offsetY = (screenSize.height - viewBoxSize.height * scaleY) / 2;
    }
    
    return _CoverTransform(scaleX, scaleY, offsetX, offsetY);
  }

  // Path üzerinde eşit aralıklı noktalar hesapla
  List<Offset> _getPointsOnPath(List<Offset> points, int count, double startRatio, double endRatio) {
    if (points.length < 2) return [];
    
    final result = <Offset>[];
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    final pathMetric = path.computeMetrics().first;
    final total = pathMetric.length;
    
    final start = total * startRatio;
    final end = total * (1.0 - endRatio);
    final avail = (end - start).clamp(1.0, total);
    final step = avail / count;
    
    for (int i = 0; i < count; i++) {
      final at = (start + step * (i + 0.5)).clamp(0.0, total - 1e-6);
      final tangent = pathMetric.getTangentForOffset(at);
      if (tangent != null) {
        result.add(tangent.position);
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Polyline'ı parse et
    final polyPts = _parsePolylinePoints(polylinePoints);
    if (polyPts.isEmpty) return const SizedBox.shrink();

    // 2. Cover dönüşümünü hesapla
    final transform = _calculateCoverTransform();

    // 3. Path'i ekran koordinatlarına dönüştür
    final screenPoints = polyPts.map((p) => 
      Offset(p.dx * transform.scaleX + transform.offsetX, 
             p.dy * transform.scaleY + transform.offsetY)
    ).toList();

    // 4. Path üzerinde buton pozisyonlarını hesapla
    final buttonPositions = _getPointsOnPath(screenPoints, levelCount, startOffsetRatio, endOffsetRatio);

    final children = <Widget>[];

    // Debug: Cover alanını göster
    if (debugShowCoverArea) {
      children.add(Positioned.fill(
        child: CustomPaint(
          painter: _CoverAreaPainter(transform, viewBoxSize),
        ),
      ));
    }

    // Debug: Path'i çiz
    if (debugShowPath) {
      children.add(Positioned.fill(
        child: CustomPaint(
          painter: _PathPainter(screenPoints),
        ),
      ));
    }

    // Level butonları
    for (int i = 0; i < buttonPositions.length; i++) {
      final pos = buttonPositions[i];
      final levelIndex = levelStart + i; // levelStart ile başlayarak doğru level numarasını kullan
      final isUnlocked = unlockedLevels.contains(levelIndex);
      final stars = levelStars[levelIndex] ?? 0;
      
      children.add(Positioned(
        left: pos.dx - buttonSize / 2,
        top: pos.dy - buttonSize / 2,
        child: _LevelCircle(
          label: '$levelIndex',
          size: buttonSize,
          isUnlocked: isUnlocked,
          stars: stars,
          onTap: isUnlocked ? () => onLevelTap(levelIndex) : null,
        ),
      ));
    }

    return Stack(clipBehavior: Clip.none, children: children);
  }
}

class _CoverTransform {
  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;

  _CoverTransform(this.scaleX, this.scaleY, this.offsetX, this.offsetY);
}

class _CoverAreaPainter extends CustomPainter {
  final _CoverTransform transform;
  final Size viewBoxSize;

  _CoverAreaPainter(this.transform, this.viewBoxSize);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      transform.offsetX,
      transform.offsetY,
      viewBoxSize.width * transform.scaleX,
      viewBoxSize.height * transform.scaleY,
    );
    
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _CoverAreaPainter oldDelegate) => false;
}

class _PathPainter extends CustomPainter {
  final List<Offset> points;

  _PathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    
    final paint = Paint()
      ..color = Colors.red.withOpacity(1.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => false;
}

class _LevelCircle extends StatelessWidget {
  const _LevelCircle({
    required this.label,
    required this.size,
    required this.isUnlocked,
    required this.stars,
    this.onTap,
  });

  final String label;
  final double size;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ana buton
          Stack(
            alignment: Alignment.center,
            children: [
              // Alt katman: Beyaz halo (glow) - sadece açık level'lar için
              if (isUnlocked)
                SizedBox(
                  width: size + 10,
                  height: size + 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                ),
              
              // Orta katman: Daire
              SizedBox(
                width: size,
                height: size,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked 
                      ? const Color(0xFF2F73FF) // açık level'lar için mavi
                      : Colors.grey.shade300, // kilitli level'lar için net gri
                    border: Border.all(
                      color: isUnlocked ? Colors.white : Colors.grey.shade400, 
                      width: 2
                    ),
                  ),
                ),
              ),
              
              // Üst katman: İçerik (rakam veya kilit simgesi)
              if (isUnlocked)
                // Açık level'lar için rakam
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                )
              else
                // Kilitli level'lar için kilit simgesi
                Icon(
                  Icons.lock,
                  color: Colors.grey.shade600,
                  size: size * 0.4,
                ),
            ],
          ),
          
          // Yıldızlar - sadece açık level'lar için
          if (isUnlocked && stars > 0)
            Transform.translate(
              offset: const Offset(0, -4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: index < stars ? Colors.amber : Colors.grey.shade400,
                    size: 10,
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}