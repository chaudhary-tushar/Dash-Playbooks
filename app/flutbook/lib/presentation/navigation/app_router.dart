// lib/presentation/navigation/app_router.dart
import 'package:flutbook/presentation/screens/auth_screen.dart';
import 'package:flutbook/presentation/screens/library_screen.dart';
import 'package:flutbook/presentation/screens/playback_screen.dart';
import 'package:flutbook/presentation/screens/settings_screen.dart';
import 'package:flutbook/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/library':
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case '/playback':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PlaybackScreen(
            audiobook: args?['audiobook'],
          ),
        );
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
