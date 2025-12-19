/// Application bootstrapper for Flutbook using Riverpod state management.
/// Implements a custom [RiverpodObserver] for logging provider lifecycle events
/// and configures global Flutter error handling before running the app.
library;

import 'dart:async';
import 'dart:developer';

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/core/provider/providers.dart';
import 'package:flutter/foundation.dart';
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

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  String? env,
}) async {
  // Ensure WidgetsFlutterBinding is initialized before using any Flutter services
  WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize application configuration
  try {
    final configProvider = ConfigProvider();
    AppEnvironment environment;

    // Use provided environment or detect based on build mode
    if (env != null) {
      switch (env.toLowerCase()) {
        case 'development':
          environment = AppEnvironment.development;
        case 'staging':
          environment = AppEnvironment.staging;
        case 'production':
          environment = AppEnvironment.production;
        default:
          environment = AppEnvironment.development; // default fallback
          print('Warning: Unknown environment "$env", defaulting to development');
      }
    } else if (kDebugMode) {
      // For development builds
      environment = AppEnvironment.development;
    } else {
      // For release builds, detect environment from build flavor
      // This can be enhanced to detect based on build-specific flags
      environment = const String.fromEnvironment('FLAVOR') == 'staging'
          ? AppEnvironment.staging
          : AppEnvironment.production;
    }
    await configProvider.initialize(environment: environment);
    print('App configuration loaded successfully');
    print(configProvider.config.getSummary());
  } catch (e) {
    print('Warning: Configuration initialization failed in bootstrap: $e');
    print('Continuing app startup with default configuration...');
  }

  // Add cross-flavor configuration here
  // Note: Supabase initialization will be handled by datasources when needed
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: await builder(),
    ),
  );
}
