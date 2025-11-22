/// Application bootstrapper for Flutbook using Riverpod state management.
/// Implements a custom [RiverpodObserver] for logging provider lifecycle events
/// and configures global Flutter error handling before running the app.
library;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // Add cross-flavor configuration here

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: await builder(),
    ),
  );
}
