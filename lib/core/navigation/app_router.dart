import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taqs/core/navigation/app_routes.dart';
import 'package:taqs/core/navigation/scaffold_with_nav_bar.dart';
import 'package:taqs/features/about/presentation/screens/about_developer_screen.dart';
import 'package:taqs/features/settings/presentation/screens/settings_screen.dart';
import 'package:taqs/features/splash/presentation/screens/splash_screen.dart';
import 'package:taqs/features/weather/presentation/screens/home_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settingsNav');

/// Provider for [GoRouter] instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // Stateful Shell with Persistent Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Home Tab Branch
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Settings Tab Branch
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // About Developer Screen (Root Navigator so it covers the shell)
      GoRoute(
        path: AppRoutes.about,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutDeveloperScreen(),
      ),
    ],
  );
});
