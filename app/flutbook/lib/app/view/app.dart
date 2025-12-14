/// Root [App] widget using MaterialApp with onGenerateRoute from AppRouter.
/// Integrates themes, localizations, and Riverpod via bootstrap.

library;

import 'package:flutbook/app/router/app_router.dart';
import 'package:flutbook/core/theme/app_theme.dart';
import 'package:flutbook/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// class App extends ConsumerWidget {
class App extends StatelessWidget {
  const App({super.key});

  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   return const MaterialApp(
  //     title: 'Flutter Audiobook Player',
  //     debugShowCheckedModeBanner: false,
  //     home: LoginPage(), // <<< IMPORTANT
  //   );
  // }
  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   final router = ref.watch(
  //     AppRouter as ProviderListenable<RouterConfig<Object>?>,
  //   );

  //   return MaterialApp.router(
  //     title: 'Flutter Audiobook Player',
  //     debugShowCheckedModeBanner: false,
  //     routerConfig: router, // <<< This enables app.router
  //   );
  // }

  @override
  Widget build(BuildContext context) {
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
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
