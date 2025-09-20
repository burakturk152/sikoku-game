import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/map_screen.dart';
import '../screens/game_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/store_screen.dart';
// import '../screens/test_grid_layout.dart'; // Artık route olarak eklenmiyor

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: SplashRoute.page,
          initial: true,
        ),
        AutoRoute(
          path: '/map',
          page: MapRoute.page,
        ),
        AutoRoute(
          path: '/game/:stage/:level',
          page: GameRoute.page,
        ),
        AutoRoute(
          path: '/profile',
          page: ProfileRoute.page,
        ),
        AutoRoute(
          path: '/settings',
          page: SettingsRoute.page,
        ),
        AutoRoute(
          path: '/store',
          page: StoreRoute.page,
        ),
        // TestGridLayout route'u kaldırıldı
      ];
}