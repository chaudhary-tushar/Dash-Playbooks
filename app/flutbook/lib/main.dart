/// Main entry point for the Flutbook audiobook player application.
/// Configures the root MaterialApp with AppTheme light/dark themes, Flutter localizations,
/// and named routes to splash, library, playback, and settings screens.
library;

import 'package:flutbook/lib/presentation/screens/library_screen.dart'; // Using library screen as main screen
import 'package:flutbook/lib/presentation/screens/playback_screen.dart';
import 'package:flutbook/lib/presentation/screens/settings_screen.dart';
import 'package:flutbook/lib/presentation/screens/splash_screen.dart';
import 'package:flutbook/lib/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AudiobookPlayerApp(),
    ),
  );
}

class AudiobookPlayerApp extends StatelessWidget {
  const AudiobookPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audiobook Player',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/splash', // Set initial route to the splash screen
      routes: <String, Widget Function(BuildContext)>{
        '/splash': (BuildContext context) => const SplashScreen(),
        '/main': (BuildContext context) =>
            const LibraryScreen(), // Use LibraryScreen as main screen
        '/library': (BuildContext context) =>
            const LibraryScreen(), // Added explicit library route
        '/settings': (BuildContext context) =>
            const SettingsScreen(), // Add settings route
        '/playback': (BuildContext context) =>
            const PlaybackScreen(), // Add playback route
      },
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
