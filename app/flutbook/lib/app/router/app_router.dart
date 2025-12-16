/// Core navigation router for the Flutbook application.
/// Defines route generation logic using [MaterialPageRoute] for key screens like splash, auth, library, and player.
library;

import 'package:flutbook/app/router/auth_guard.dart';
import 'package:flutbook/features/auth/presentation/login.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutbook/features/directory_selection/presentation/view/directory_selection_screen.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/presentation/views/library_screen.dart';
import 'package:flutbook/features/player/presentation/views/playback_screen.dart';
import 'package:flutbook/features/settings/presentation/view/settings_screen.dart';
import 'package:flutbook/features/splash/presentation/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouter {
  AppRouter(this.authState);
  final AuthState authState;

  Route<dynamic> generateRoute(RouteSettings settings) {
    // Check if route can be activated using AuthGuard
    final canActivate = AuthGuard.canActivate(settings.name ?? '/', authState);

    // If cannot activate and not already on auth page, redirect to auth
    if (!canActivate && settings.name != '/auth') {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }

    // Existing route generation logic
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/library':
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case '/directory':
        final args = settings.arguments! as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DirectorySelectionScreen(
            initialDirectory: args['initialDirectory'] as String?,
          ),
        );
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

/// Router provider that can access auth state
final routerProvider = Provider<AppRouter>((ref) {
  final authState = ref.watch(authProvider);
  return AppRouter(authState);
});
