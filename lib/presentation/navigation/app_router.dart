// lib/presentation/navigation/app_router.dart
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/library_screen.dart';
import '../screens/playback_screen.dart';
import '../screens/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => AuthScreen());
      case '/library':
        return MaterialPageRoute(builder: (_) => LibraryScreen());
      case '/playback':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PlaybackScreen(
            audiobook: args?['audiobook'],
          ),
        );
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}