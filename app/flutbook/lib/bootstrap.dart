/// Application bootstrapper for Flutbook using Riverpod state management.
/// Implements a custom [RiverpodObserver] for logging provider lifecycle events
/// and configures global Flutter error handling before running the app.
library;

import 'dart:async';
import 'dart:developer';

import 'package:flutbook/core/provider/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Custom observer for Riverpod provider state changes.
/// Logs all provider lifecycle events for debugging and monitoring.
final class RiverpodObserver extends ProviderObserver {
  const RiverpodObserver();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    log(
      'didUpdateProvider: ${context.provider.runtimeType} '
      'previousValue=$previousValue, newValue=$newValue',
    );
  }

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    log('didAddProvider: ${context.provider.runtimeType} value=$value');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    log('didDisposeProvider: ${context.provider.runtimeType}');
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Handle Flutter errors globally
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // Create a ProviderContainer with custom observer for state management logging
  final container = ProviderContainer(
    observers: [const RiverpodObserver()],
  );

  // Initialize the database service early - this must happen before any datasource tries to use Isar
  try {
    await container.read(databaseServiceProvider.future);
  } catch (e) {
    print('Warning: Database initialization failed in bootstrap: $e');
  }

  // Add cross-flavor configuration here
  // Ensure GoogleSignIn is initialized for google_sign_in v7+ when using flavor mains
  try {
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    // Log and continue; initialization failures should not crash bootstrap.
    // Use a logging framework in production instead of print.
    print('Warning: GoogleSignIn.initialize() failed in bootstrap: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: await builder(),
    ),
  );
}
