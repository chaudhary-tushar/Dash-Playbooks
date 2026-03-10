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
  try {
    WidgetsFlutterBinding.ensureInitialized();
    log('WidgetsFlutterBinding initialized successfully');
  } catch (e) {
    log('ERROR: Failed to initialize WidgetsFlutterBinding: $e', level: 1000);
    rethrow;
  }

  // Handle Flutter errors globally
  FlutterError.onError = (details) {
    log(
      'Flutter Error: ${details.exception}',
      stackTrace: details.stack,
    );
  };
  log('Global error handler configured');

  // Create a ProviderContainer with custom observer for state management logging
  try {
    final container = ProviderContainer(
      observers: [const RiverpodObserver()],
    );
    log('ProviderContainer created successfully');

    // Initialize the database service early - this must happen before any datasource tries to use Isar
    try {
      final databaseFuture = container.read(databaseServiceProvider.future);

      await databaseFuture;
    } catch (e, stackTrace) {
      log(
        'ERROR: Database initialization failed: $e',
        level: 1000,
        stackTrace: stackTrace,
      );
      // Continue execution but log the error
    }

    // Initialize audio services early - this must happen before any audio operations
    try {
      final audioInitFuture = container.read(audioInitializationServiceProvider.future);

      await audioInitFuture;
    } catch (e, stackTrace) {
      log(
        'ERROR: Audio initialization failed: $e',
        level: 1000,
        stackTrace: stackTrace,
      );
      // Continue execution but log the error
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
            print(
              'Warning: Unknown environment "$env", defaulting to development',
            );
        }
      } else if (kDebugMode) {
        // For development builds
        environment = AppEnvironment.development;
      } else {
        // For release builds, detect environment from build flavor
        const flavor = String.fromEnvironment('FLAVOR');

        environment = flavor == 'staging'
            ? AppEnvironment.staging
            : AppEnvironment.production;
      }

      log('Initializing config provider with environment: ${environment.name}');
      await configProvider.initialize(environment: environment);

      log('App configuration loaded successfully');
      print('App configuration loaded successfully');
      print(configProvider.config.getSummary());
    } catch (e, stackTrace) {
      log(
        'ERROR: Configuration initialization failed: $e',
        level: 1000,
        stackTrace: stackTrace,
      );
      print('Warning: Configuration initialization failed in bootstrap: $e');
      print('Continuing app startup with default configuration...');
      // Continue with default configuration
    }

    // Add cross-flavor configuration here
    // Note: Supabase initialization will be handled by datasources when needed
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: await builder(),
      ),
    );
    log('Application started successfully');
  } catch (e, stackTrace) {
    log('CRITICAL ERROR in bootstrap: $e', level: 1000, stackTrace: stackTrace);
    rethrow;
  }
}
