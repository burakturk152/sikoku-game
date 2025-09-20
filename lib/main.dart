import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'routes/app_router.dart';
import 'bloc/level_progress_cubit.dart';
import 'bloc/theme_cubit.dart';
import 'bloc/game_stats_cubit.dart';
import 'services/shared_pref_helper.dart';
import 'widgets/theme_toggle_button.dart';
import 'bloc/profile_cubit.dart';
import 'theme/app_themes.dart';
import 'inventory/inventory_cubit.dart';
import 'inventory/inventory_repository.dart';
import 'admin/admin_mode_cubit.dart';
import 'admin/admin_mode_repository.dart';
import 'settings/settings_cubit.dart';
import 'store/store_cubit.dart';
import 'core/notification_service.dart';
import 'audio/audio_gateway.dart';
import 'l10n/app_localizations.dart';
import 'services/puzzle_prefetch_service.dart';
import 'services/github_puzzle_provider.dart';
import 'services/remote_puzzle_provider.dart';
import 'services/puzzle_loader_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Windows için pencere boyutunu telefon boyutuna ayarla
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    
    // Tipik telefon boyutu: 375x667 (iPhone 6/7/8 boyutu)
    // Alternatif: 360x640 (Android standart boyutu)
    const phoneWidth = 375.0;
    const phoneHeight = 667.0;
    
    // Pencere boyutunu ve pozisyonunu ayarla
    await windowManager.setSize(Size(phoneWidth, phoneHeight));
    await windowManager.setMinimumSize(Size(phoneWidth, phoneHeight));
    await windowManager.setMaximumSize(Size(phoneWidth, phoneHeight));
    
    // Pencereyi ekranın ortasına konumlandır
    await windowManager.center();
    
    // Pencere başlığını ayarla
    await windowManager.setTitle('SIKOKU - Telefon Modu');
  }
  
  await initializeDateFormatting('tr_TR');
  await NotificationService().initialize();
  configureEasyLoading();
  final initialThemeMode = await SharedPrefHelper.getSavedThemeMode();
  
  // AudioGateway'i başlat
  final audioGateway = AudioGateway();
  await audioGateway.startBackgroundMusic();
  
  // Puzzle prefetch'i başlat (arka planda)
  _startPuzzlePrefetch();
  
  runApp(MyApp(initialThemeMode: initialThemeMode));
}

// Puzzle prefetch fonksiyonu
void _startPuzzlePrefetch() async {
  try {
    final prefetchService = PuzzlePrefetchService(
      github: GitHubPuzzleProvider(),
      remote: RemotePuzzleProvider(),
      source: PuzzleSource.hybrid,
    );
    
    // Arka planda prefetch yap
    await prefetchService.prefetchTodayAndThisWeek();
  } catch (e) {
    debugPrint('Puzzle prefetch failed: $e');
  }
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  MyApp({Key? key, required this.initialThemeMode}) : super(key: key);

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameStatsCubit>(
          create: (context) => GameStatsCubit(),
        ),
        BlocProvider<LevelProgressCubit>(
          create: (context) => LevelProgressCubit(
            onStarsUpdated: () {
              context.read<GameStatsCubit>().updateTotalStarsFromLevelProgress();
            },
          ),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(initialThemeMode),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(),
        ),
        BlocProvider<InventoryCubit>(
          create: (context) => InventoryCubit(InventoryRepository())..init(),
        ),
        BlocProvider<AdminModeCubit>(
          create: (context) => AdminModeCubit(AdminModeRepository())..init(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit()..init(),
        ),
        BlocProvider<StoreCubit>(
          create: (context) => StoreCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.select((ThemeCubit c) => c.state.themeMode);
          final locale = context.select((SettingsCubit c) => c.currentLocale);
          
          return MaterialApp.router(
            title: 'SIKOKU',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeMode,
            locale: locale,
            supportedLocales: const [
              Locale('tr'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // Bilinmeyen dilde İngilizce'ye düş
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return const Locale('en');
            },
            routerConfig: _appRouter.config(),
            builder: EasyLoading.init(
              builder: (context, child) {
                final size = MediaQuery.sizeOf(context);
                final double topPadding = size.height * 0.02;
                final double rightPadding = size.width * 0.02;
                return child ?? const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}

void configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.purple
    ..backgroundColor = Colors.black.withOpacity(0.8)
    ..indicatorColor = Colors.purple
    ..textColor = Colors.white
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
} 