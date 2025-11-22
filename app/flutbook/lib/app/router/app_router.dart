/// Core navigation router for the Flutbook application.
/// Defines route generation logic using [MaterialPageRoute] for key screens like splash, auth, library, and playback.
library;

import 'package:flutbook/features/auth/presentation/login.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/presentation/views/library_screen.dart';
import 'package:flutbook/features/playback/presentation/views/playback_screen.dart';
import 'package:flutbook/features/settings/presentation/view/settings_screen.dart';
import 'package:flutbook/features/splash/presentation/view/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/library':
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case '/playback':
        final args = settings.arguments as Map<String, AudiobookModel>?;
        return MaterialPageRoute(
          builder: (_) => PlaybackScreen(
            audiobook: args!['audiobook']!,
          ),
        );
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
