// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    GameRoute.name: (routeData) {
      final args = routeData.argsAs<GameRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: GameScreen(
          key: args.key,
          stage: args.stage,
          level: args.level,
          dailyDate: args.dailyDate,
          weeklyMonday: args.weeklyMonday,
        ),
      );
    },
    MapRoute.name: (routeData) {
      final args =
          routeData.argsAs<MapRouteArgs>(orElse: () => const MapRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MapScreen(
          key: args.key,
          stage: args.stage,
        ),
      );
    },
    ProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileScreen(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsScreen(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    StoreRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const StoreScreen(),
      );
    },
  };
}

/// generated route for
/// [GameScreen]
class GameRoute extends PageRouteInfo<GameRouteArgs> {
  GameRoute({
    Key? key,
    required int stage,
    required int level,
    DateTime? dailyDate,
    DateTime? weeklyMonday,
    List<PageRouteInfo>? children,
  }) : super(
          GameRoute.name,
          args: GameRouteArgs(
            key: key,
            stage: stage,
            level: level,
            dailyDate: dailyDate,
            weeklyMonday: weeklyMonday,
          ),
          initialChildren: children,
        );

  static const String name = 'GameRoute';

  static const PageInfo<GameRouteArgs> page = PageInfo<GameRouteArgs>(name);
}

class GameRouteArgs {
  const GameRouteArgs({
    this.key,
    required this.stage,
    required this.level,
    this.dailyDate,
    this.weeklyMonday,
  });

  final Key? key;

  final int stage;

  final int level;

  final DateTime? dailyDate;

  final DateTime? weeklyMonday;

  @override
  String toString() {
    return 'GameRouteArgs{key: $key, stage: $stage, level: $level, dailyDate: $dailyDate, weeklyMonday: $weeklyMonday}';
  }
}

/// generated route for
/// [MapScreen]
class MapRoute extends PageRouteInfo<MapRouteArgs> {
  MapRoute({
    Key? key,
    int stage = 1,
    List<PageRouteInfo>? children,
  }) : super(
          MapRoute.name,
          args: MapRouteArgs(
            key: key,
            stage: stage,
          ),
          initialChildren: children,
        );

  static const String name = 'MapRoute';

  static const PageInfo<MapRouteArgs> page = PageInfo<MapRouteArgs>(name);
}

class MapRouteArgs {
  const MapRouteArgs({
    this.key,
    this.stage = 1,
  });

  final Key? key;

  final int stage;

  @override
  String toString() {
    return 'MapRouteArgs{key: $key, stage: $stage}';
  }
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [StoreScreen]
class StoreRoute extends PageRouteInfo<void> {
  const StoreRoute({List<PageRouteInfo>? children})
      : super(
          StoreRoute.name,
          initialChildren: children,
        );

  static const String name = 'StoreRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
