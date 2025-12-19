/// Application configuration management for different environments.
///
/// This module provides:
/// - Environment-specific configuration loading
/// - Runtime configuration injection
/// - Feature flag management
/// - Supabase connection configuration
library;

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application environment types
enum AppEnvironment {
  development,
  staging,
  production;

  /// Get environment name as string
  String get name => switch (this) {
    AppEnvironment.development => 'development',
    AppEnvironment.staging => 'staging',
    AppEnvironment.production => 'production',
  };
}

/// Supabase connection configuration
class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    required this.serviceRoleKey,
  });

  /// Create config from environment variables
  factory SupabaseConfig.fromEnv() {
    final url =
        dotenv.env['SUPABASE_URL'] ??
        (kDebugMode ? 'http://localhost:54321' : '');
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

    if (url.isEmpty) {
      throw ConfigException('SUPABASE_URL is required');
    }
    if (anonKey.isEmpty) {
      throw ConfigException('SUPABASE_ANON_KEY is required');
    }
    if (serviceRoleKey.isEmpty) {
      throw ConfigException('SUPABASE_SERVICE_ROLE_KEY is required');
    }

    return SupabaseConfig(
      url: url,
      anonKey: anonKey,
      serviceRoleKey: serviceRoleKey,
    );
  }
  final String url;
  final String anonKey;
  final String serviceRoleKey;
}

/// API configuration settings
class ApiConfig {
  const ApiConfig({
    required this.timeout,
    required this.maxRetryAttempts,
    required this.poolSize,
    required this.dbTimeout,
  });

  /// Create config from environment variables with defaults
  factory ApiConfig.fromEnv() {
    return ApiConfig(
      timeout: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'),
      maxRetryAttempts: int.parse(dotenv.env['MAX_RETRY_ATTEMPTS'] ?? '3'),
      poolSize: int.parse(dotenv.env['DB_POOL_SIZE'] ?? '10'),
      dbTimeout: int.parse(dotenv.env['DB_TIMEOUT'] ?? '5000'),
    );
  }
  final int timeout;
  final int maxRetryAttempts;
  final int poolSize;
  final int dbTimeout;
}

/// Authentication configuration settings
class AuthConfig {
  const AuthConfig({
    required this.timeout,
    required this.enableGoogleAuth,
    required this.enableEmailAuth,
    required this.enableAnonymousAuth,
  });

  /// Create config from environment variables with defaults
  factory AuthConfig.fromEnv() {
    return AuthConfig(
      timeout: int.parse(dotenv.env['AUTH_TIMEOUT'] ?? '10000'),
      enableGoogleAuth: dotenv.env['ENABLE_GOOGLE_AUTH'] == 'true',
      enableEmailAuth: dotenv.env['ENABLE_EMAIL_AUTH'] == 'true',
      enableAnonymousAuth: dotenv.env['ENABLE_ANONYMOUS_AUTH'] == 'true',
    );
  }
  final int timeout;
  final bool enableGoogleAuth;
  final bool enableEmailAuth;
  final bool enableAnonymousAuth;
}

/// Synchronization configuration settings
class SyncConfig {
  const SyncConfig({
    required this.interval,
    required this.maxConcurrentSyncs,
    required this.enableBackgroundSync,
  });

  /// Create config from environment variables with defaults
  factory SyncConfig.fromEnv() {
    return SyncConfig(
      interval: int.parse(dotenv.env['SYNC_INTERVAL'] ?? '60000'),
      maxConcurrentSyncs: int.parse(dotenv.env['MAX_CONCURRENT_SYNCS'] ?? '3'),
      enableBackgroundSync: dotenv.env['ENABLE_BACKGROUND_SYNC'] == 'true',
    );
  }
  final int interval;
  final int maxConcurrentSyncs;
  final bool enableBackgroundSync;
}

/// Logging configuration settings
class LoggingConfig {
  const LoggingConfig({
    required this.level,
    required this.enableConsoleLogs,
    required this.enableRemoteLogs,
  });

  /// Create config from environment variables with defaults
  factory LoggingConfig.fromEnv() {
    return LoggingConfig(
      level: dotenv.env['LOG_LEVEL'] ?? (kDebugMode ? 'debug' : 'warn'),
      enableConsoleLogs: dotenv.env['ENABLE_CONSOLE_LOGS'] == 'true',
      enableRemoteLogs: dotenv.env['ENABLE_REMOTE_LOGS'] == 'true',
    );
  }
  final String level;
  final bool enableConsoleLogs;
  final bool enableRemoteLogs;
}

/// Feature flags configuration
class FeatureFlags {
  const FeatureFlags({
    required this.enableRealTimeSync,
    required this.enableOfflineMode,
    required this.enableAnalytics,
    required this.enableSslPins,
    required this.enableCertificateValidation,
  });

  /// Create config from environment variables with defaults
  factory FeatureFlags.fromEnv() {
    return FeatureFlags(
      enableRealTimeSync: dotenv.env['ENABLE_REAL_TIME_SYNC'] == 'true',
      enableOfflineMode: dotenv.env['ENABLE_OFFLINE_MODE'] == 'true',
      enableAnalytics: dotenv.env['ENABLE_ANALYTICS'] == 'true',
      enableSslPins: dotenv.env['ENABLE_SSL_PINS'] == 'true',
      enableCertificateValidation:
          dotenv.env['ENABLE_CERTIFICATE_VALIDATION'] == 'true',
    );
  }
  final bool enableRealTimeSync;
  final bool enableOfflineMode;
  final bool enableAnalytics;
  final bool enableSslPins;
  final bool enableCertificateValidation;
}

/// Main application configuration
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.debug,
    required this.supabase,
    required this.api,
    required this.auth,
    required this.sync,
    required this.logging,
    required this.features,
  });
  final AppEnvironment environment;
  final bool debug;
  final SupabaseConfig supabase;
  final ApiConfig api;
  final AuthConfig auth;
  final SyncConfig sync;
  final LoggingConfig logging;
  final FeatureFlags features;

  /// Load configuration from environment files based on build flavor
  static Future<AppConfig> load({
    AppEnvironment? environment,
  }) async {
    // Determine environment
    final env = environment ?? _detectEnvironment();

    // Load appropriate .env file
    await _loadEnvironmentFile(env);

    // Create configuration from environment variables
    final supabase = SupabaseConfig.fromEnv();
    final api = ApiConfig.fromEnv();
    final auth = AuthConfig.fromEnv();
    final sync = SyncConfig.fromEnv();
    final logging = LoggingConfig.fromEnv();
    final features = FeatureFlags.fromEnv();

    final config = AppConfig(
      environment: env,
      debug: kDebugMode,
      supabase: supabase,
      api: api,
      auth: auth,
      sync: sync,
      logging: logging,
      features: features,
    );

    // Log configuration (excluding sensitive data)
    log('AppConfig loaded for environment: ${env.name}');
    log('Supabase URL: ${supabase.url}');
    log('Debug mode: $kDebugMode');
    log(
      'Features: RealTime=${features.enableRealTimeSync}, '
      'Offline=${features.enableOfflineMode}, '
      'Analytics=${features.enableAnalytics}',
    );

    return config;
  }

  /// Detect environment based on build configuration
  static AppEnvironment _detectEnvironment() {
    if (kDebugMode) {
      return AppEnvironment.development;
    }
    // In release mode, we need to determine based on build flavor
    // This is a simplified detection - in practice, you might want
    // to use build_config or similar package
    return AppEnvironment.production;
  }

  /// Load environment file based on environment
  static Future<void> _loadEnvironmentFile(AppEnvironment environment) async {
    final fileName = '.env.${environment.name}';

    try {
      await dotenv.load(fileName: fileName);
      log('Loaded environment file: $fileName');
    } catch (e) {
      log('Failed to load $fileName: $e');
      log('Falling back to default .env file');

      // Try to load default .env file
      try {
        await dotenv.load();
      } catch (e) {
        log('Failed to load default .env file: $e');
        log('Continuing with system environment variables only');
      }
    }
  }

  /// Get configuration summary (safe for logging)
  String getSummary() {
    return '''
AppConfig Summary:
  Environment: ${environment.name}
  Debug: $debug
  Supabase URL: ${supabase.url}
  API Timeout: ${api.timeout}ms
  Auth Timeout: ${auth.timeout}ms
  Sync Interval: ${sync.interval}ms
  Features:
    - Real-time sync: ${features.enableRealTimeSync}
    - Offline mode: ${features.enableOfflineMode}
    - Analytics: ${features.enableAnalytics}
''';
  }
}

/// Configuration loading exception
class ConfigException implements Exception {
  ConfigException(this.message);
  final String message;

  @override
  String toString() => 'ConfigException: $message';
}

/// Configuration provider for Riverpod
/// This allows dependency injection of configuration throughout the app
class ConfigProvider {
  factory ConfigProvider() => _instance;

  ConfigProvider._internal();
  static final _instance = ConfigProvider._internal();
  AppConfig? _config;

  /// Initialize configuration
  Future<void> initialize({AppEnvironment? environment}) async {
    _config = await AppConfig.load(environment: environment);
  }

  /// Get current configuration
  AppConfig get config {
    if (_config == null) {
      throw ConfigException(
        'Configuration not initialized. Call initialize() first.',
      );
    }
    return _config!;
  }

  /// Check if configuration is initialized
  bool get isInitialized => _config != null;
}
