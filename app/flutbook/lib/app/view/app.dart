/// Root widget in the app presentation layer for Flutbook.
/// ConsumerWidget building MaterialApp with LoginPage as home and Riverpod integration.
library;

import 'package:flutbook/app/router/app_router.dart';

// import 'package:flutbook/features/auth/presentation/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart';

class App extends ConsumerWidget {
  const App({super.key});

  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   return const MaterialApp(
  //     title: 'Flutter Audiobook Player',
  //     debugShowCheckedModeBanner: false,
  //     home: LoginPage(), // <<< IMPORTANT
  //   );
  // }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(
      AppRouter as ProviderListenable<RouterConfig<Object>?>,
    );

    return MaterialApp.router(
      title: 'Flutter Audiobook Player',
      debugShowCheckedModeBanner: false,
      routerConfig: router, // <<< This enables app.router
    );
  }
}
