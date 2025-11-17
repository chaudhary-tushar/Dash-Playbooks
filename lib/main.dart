import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/splash_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(
    ProviderScope(
      child: AudiobookPlayerApp(),
    ),
  );
}

class AudiobookPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audiobook Player',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      initialRoute: '/splash', // Set initial route to the splash screen
      routes: <String, Widget Function(BuildContext)>{
        '/splash': (BuildContext context) => const SplashScreen(),
        '/main': (BuildContext context) => const MainScreen(), // Define the main screen route
      },
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}