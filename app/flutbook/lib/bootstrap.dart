import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom observer for Riverpod provider state changes.
/// Logs all provider lifecycle events for debugging and monitoring.
class RiverpodObserver extends ProviderObserver {
  const RiverpodObserver();

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousState,
    Object? newState,
    ProviderContainer container,
  ) {
    log(
      'didUpdateProvider: ${provider.runtimeType} '
      'previousState=$previousState, newState=$newState',
    );
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    log('didAddProvider: ${provider.runtimeType} value=$value');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    log('didDisposeProvider: ${provider.runtimeType}');
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
