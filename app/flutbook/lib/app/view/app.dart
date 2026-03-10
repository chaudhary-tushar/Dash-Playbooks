/// Root [App] widget using MaterialApp with onGenerateRoute from AppRouter.
/// Integrates themes, localizations, and Riverpod via bootstrap.

library;

import 'package:flutbook/app/router/auth_guard.dart';
import 'package:flutbook/core/services/navigation_service.dart';
import 'package:flutbook/core/theme/app_theme.dart';
import 'package:flutbook/features/auth/presentation/login.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutbook/features/directory_selection/presentation/view/directory_selection_screen.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/presentation/views/library_screen.dart';
import 'package:flutbook/features/player/presentation/views/playback_screen.dart';
import 'package:flutbook/features/settings/presentation/view/settings_screen.dart';
import 'package:flutbook/features/splash/presentation/view/splash_screen.dart';
import 'package:flutbook/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a guarded watch to handle provider errors gracefully
    final authState = ref.watch(authProvider);

    // Pre-read the auth state to avoid using ref in onGenerateRoute
    final currentAuthState = ref.read(authProvider);

    // Create a wrapper function to handle route generation
    Route<Object>? onGenerateRoute(RouteSettings settings) {
      // Check if route can be activated using AuthGuard
      final canActivate = AuthGuard.canActivate(
        settings.name ?? '/',
        currentAuthState,
      );

      // If cannot activate and not already on auth page, redirect to auth
      // But allow development bypass for specific routes
      if (!canActivate && settings.name != '/auth' && settings.name != 'dev_directory') {
        return MaterialPageRoute(builder: (_) => const LoginPage());
      }

      // Existing route generation logic
      switch (settings.name) {
        case '/':
          // During loading state, show splash screen; otherwise, show based on auth state
          if (authState.isLoading) {
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          } else {
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        case '/auth':
          return MaterialPageRoute(builder: (_) => const LoginPage());
        case '/library':
          return MaterialPageRoute(builder: (_) => const LibraryScreen());
        case '/directory':
        case 'dev_directory': // Development bypass route
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => DirectorySelectionScreen(
              initialDirectory: args?['initialDirectory'] as String?,
            ),
          );
        case '/playback':
          // Handle both direct Audiobook object and Map<String, AudiobookModel> format
          if (settings.arguments != null && settings.arguments is Audiobook) {
            final audiobook = settings.arguments as Audiobook;
            return MaterialPageRoute(
              builder: (_) => PlaybackScreen(audiobook: audiobook),
            );
          } else if (settings.arguments != null &&
              settings.arguments is Map<String, AudiobookModel>) {
            final args = settings.arguments as Map<String, AudiobookModel>;
            final audiobookData = args['audiobook'];
            if (audiobookData != null) {
              return MaterialPageRoute(
                builder: (_) => PlaybackScreen(
                  audiobook: audiobookData.toDomain(),
                ),
              );
            } else {
              // Handle case where 'audiobook' key is missing or null
              throw Exception(
                'Missing audiobook data in arguments for /playback route',
              );
            }
          } else if (settings.arguments != null) {
            // Fallback or error handling for invalid argument types
            throw Exception('Invalid arguments type for /playback route');
          } else {
            // Handle case where no arguments are provided
            throw Exception('No arguments provided for /playback route');
          }
        case '/settings':
          return MaterialPageRoute(builder: (_) => const SettingsScreen());
        default:
          return MaterialPageRoute(builder: (_) => const SplashScreen());
      }
    }

    // Use a single MaterialApp for the entire app lifecycle
    // This ensures that navigation works properly regardless of auth state
    return MaterialApp(
      title: 'Flutbook',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      // Show splash screen as initial route, which will handle auth state internally
      initialRoute: '/',
      onGenerateRoute: onGenerateRoute,
      // Handle unknown routes gracefully
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: settings,
      ),
    );
  }
}
