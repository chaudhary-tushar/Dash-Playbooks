/// Root [App] widget using MaterialApp with onGenerateRoute from AppRouter.
/// Integrates themes, localizations, and Riverpod via bootstrap.

library;

import 'package:flutbook/app/router/app_router.dart';
import 'package:flutbook/core/theme/app_theme.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutbook/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final router = AppRouter(authState);

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
      onGenerateRoute: router.generateRoute,
    );
  }
}
