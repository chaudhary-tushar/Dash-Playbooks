/// Dependency Injection configuration for Flutbook using Riverpod.
///
/// This file wires all application dependencies in the correct order:
/// 1. DatabaseService - Initializes Isar database
/// 2. Datasources - Depend on DatabaseService
/// 3. Use Cases - Depend on datasources
/// 4. Repositories - Depend on datasources and use cases
/// 5. Notifiers - Depend on repositories
library;

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/services/database_service.dart';
import 'package:flutbook/core/services/json_storage_service.dart';
import 'package:flutbook/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:flutbook/features/auth/data/repositories/user_repository_impl.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/anonymous_login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutbook/features/directory_selection/data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/directory_selection/domain/usecases/scan_library_usecase.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';
import 'package:flutbook/features/library/data/datasources/remote/supabase_library_sync.dart';
import 'package:flutbook/features/library/data/repositories/library_repository_impl.dart';
import 'package:flutbook/features/library/domain/repositories/library_repository.dart';
import 'package:flutbook/features/library/domain/services/audiobook_grouping_service.dart';
import 'package:flutbook/features/player/data/datasources/playback_local_ds.dart';
import 'package:flutbook/features/player/data/datasources/remote/supabase_playback_sync.dart';
import 'package:flutbook/features/player/data/repositories/playback_repository_impl.dart';
import 'package:flutbook/features/settings/data/datasources/preferences_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Export grouping service
export 'package:flutbook/features/library/domain/services/audiobook_grouping_service.dart'
    show AudiobookGroupingService;
// Export library provider from its own file
export 'package:flutbook/features/library/presentation/providers/library_provider.dart'
    show libraryProvider;
// Export playback providers
export 'package:flutbook/features/player/data/repositories/playback_repository_impl.dart'
    show PlaybackRepositoryImpl;

// =============================================================================
// DATABASE SERVICE PROVIDER
// =============================================================================

/// Provides the DatabaseService singleton, initializing Isar on first access.
/// This must be initialized before any datasource tries to access the database.
final databaseServiceProvider = FutureProvider<DatabaseService>((ref) async {
  final service = DatabaseService();
  await service.init();
  return service;
});

// =============================================================================
// JSON STORAGE PROVIDER
// =============================================================================

/// Provides the JsonStorage service for persisting app settings.
final jsonStorageProvider = Provider<JsonStorage>((ref) {
  return JsonStorage();
});

// =============================================================================
// METADATA EXTRACTION DATASOURCE PROVIDER
// =============================================================================

/// Provides MetadataExtractionDatasource for scanning directories and extracting metadata.
///
/// This datasource:
/// - Scans directories for audio files
/// - Extracts metadata from individual files
/// - Does NOT depend on the database
final metadataExtractionDatasourceProvider =
    Provider<MetadataExtractionDatasource>((ref) {
      return MetadataExtractionDatasource();
    });

// =============================================================================
// AUDIOBOOK LOCAL DATASOURCE PROVIDER
// =============================================================================

/// Provides AudiobookLocalDatasource for database operations.
///
/// This datasource:
/// - Stores and retrieves audiobooks from Isar
/// - Queries the database
/// - Does NOT depend on metadata extraction
///
/// **Important**: The DatabaseService must be initialized before this datasource is used.
final audiobookLocalDatasourceProvider =
    FutureProvider<AudiobookLocalDatasource>((ref) async {
      // Wait for database service to be initialized
      final databaseService = await ref.watch(databaseServiceProvider.future);
      final jsonStorage = ref.watch(jsonStorageProvider);

      return AudiobookLocalDatasource(
        databaseService.isar,
        jsonStorage: jsonStorage,
      );
    });

// =============================================================================
// PLAYBACK LOCAL DATASOURCE PROVIDER
// =============================================================================

/// Provides PlaybackLocalDatasource for database operations.
///
/// This datasource:
/// - Stores and retrieves playback sessions and history from Isar
/// - Queries the database for playback-related data
///
/// **Important**: The DatabaseService must be initialized before this datasource is used.
final playbackLocalDatasourceProvider = FutureProvider<PlaybackLocalDatasource>(
  (ref) async {
    // Wait for database service to be initialized
    final databaseService = await ref.watch(databaseServiceProvider.future);

    return PlaybackLocalDatasource(databaseService.isar);
  },
);

// =============================================================================
// PLAYBACK REPOSITORY PROVIDER
// =============================================================================

/// Provides PlaybackRepositoryImpl for playback operations.
///
/// This repository:
/// - Manages playback sessions and history
/// - Handles local and remote synchronization
/// - Provides graceful degradation when datasources are not available
/// - Implements retry mechanisms for failed initializations
final playbackRepositoryProvider = FutureProvider<PlaybackRepositoryImpl>((
  ref,
) async {
  const maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      // Ensure database service is initialized first
      await ref.watch(databaseServiceProvider.future);

      // Wait for the local datasource to be initialized
      final localDatasource = await ref.watch(
        playbackLocalDatasourceProvider.future,
      );

      // Get remote datasource (may be null for anonymous users)
      final remoteDatasource = ref.watch(playbackRemoteDatasourceProvider);

      return PlaybackRepositoryImpl(
        localDatasource: localDatasource,
        remoteDatasource: remoteDatasource,
      );
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        throw UninitializedDatasourceException(
          'Failed to initialize PlaybackRepository after $maxRetries attempts: ${ErrorHandler.handleException(e)}',
        );
      }

      // Wait before retrying
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  // This line should never be reached due to the retry logic above
  throw UninitializedDatasourceException(
    'PlaybackRepository initialization failed',
  );
});

// =============================================================================
// SCAN LIBRARY USE CASE PROVIDER
// =============================================================================

// =============================================================================
// CONFIG PROVIDER
// =============================================================================

/// Provides the ConfigProvider for accessing application configuration.
final appConfigProvider = Provider<ConfigProvider>((ref) {
  final provider = ConfigProvider();
  // Initialize config if not already done
  if (!provider.isInitialized) {
    provider.initialize();
  }
  return provider;
});

// =============================================================================
// SUPABASE CLIENT PROVIDER
// =============================================================================

/// Provides the Supabase client for all Supabase operations.
/// This must be initialized before any Supabase datasource is used.
final supabaseClientProvider = FutureProvider<SupabaseClient>((ref) async {
  final configProvider = ref.watch(appConfigProvider);
  final supabaseConfig = configProvider.config.supabase;

  await Supabase.initialize(
    url: supabaseConfig.url,
    anonKey: supabaseConfig.anonKey,
  );

  return Supabase.instance.client;
});

// =============================================================================
// AUTHENTICATION PROVIDERS
// =============================================================================

/// Provides the Supabase authentication datasource.
/// This handles all Supabase authentication operations.
final supabaseAuthDatasourceProvider = Provider<SupabaseAuthDatasource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider).value;
  final configProvider = ref.watch(appConfigProvider);

  if (supabaseClient == null) {
    throw Exception('Supabase client not initialized');
  }

  return SupabaseAuthDatasource(
    supabase: supabaseClient,
    configProvider: configProvider,
  );
});

/// Provides the Preferences datasource.
/// This handles user preferences and settings storage.
final preferencesDatasourceProvider = Provider<PreferencesDatasource>((ref) {
  return PreferencesDatasource();
});

/// Provides the Library Remote datasource.
/// This handles remote library operations with Supabase.
final libraryRemoteDatasourceProvider = Provider<SupabaseLibraryDatasource>((
  ref,
) {
  final supabaseClient = ref.watch(supabaseClientProvider).value;
  final configProvider = ref.watch(appConfigProvider);

  if (supabaseClient == null) {
    throw Exception('Supabase client not initialized');
  }

  return SupabaseLibraryDatasource(
    supabase: supabaseClient,
    configProvider: configProvider,
  );
});

/// Provides the Playback Remote datasource.
/// This handles remote playback progress operations with Supabase.
final playbackRemoteDatasourceProvider = Provider<SupabasePlaybackDatasource>((
  ref,
) {
  final supabaseClient = ref.watch(supabaseClientProvider).value;
  final configProvider = ref.watch(appConfigProvider);

  if (supabaseClient == null) {
    throw Exception('Supabase client not initialized');
  }

  return SupabasePlaybackDatasource(
    supabase: supabaseClient,
    configProvider: configProvider,
  );
});

/// Provides the User Repository implementation.
/// This depends on the auth datasource and other remote datasources.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    authDatasource: ref.watch(supabaseAuthDatasourceProvider),
    syncDatasource: ref.watch(libraryRemoteDatasourceProvider),
    playbackRemoteDatasource: ref.watch(playbackRemoteDatasourceProvider),
    preferencesDatasource: ref.watch(preferencesDatasourceProvider),
  );
});

/// Provides the Login usecase.
/// This depends on the user repository.
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(userRepositoryProvider));
});

/// Provides the Anonymous Login usecase.
/// This depends on the user repository.
final anonymousLoginUsecaseProvider = Provider<AnonymousLoginUsecase>((ref) {
  return AnonymousLoginUsecase(ref.watch(userRepositoryProvider));
});

/// Provides the Google Sign-in usecase.
/// This depends on the user repository.
final googleSigninUsecaseProvider = Provider<GoogleSigninUsecase>((ref) {
  return GoogleSigninUsecase(ref.watch(userRepositoryProvider));
});

/// Provides the Logout usecase.
/// This depends on the user repository.
final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.watch(userRepositoryProvider));
});

/// Provides the Get Current User usecase.
/// This depends on the user repository.
final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(ref.watch(userRepositoryProvider));
});

/// Provides the Signup usecase.
/// This depends on the user repository.
final signupUsecaseProvider = Provider<SignupUsecase>((ref) {
  return SignupUsecase(ref.watch(userRepositoryProvider));
});

// =============================================================================
// AUDIOBOOK GROUPING SERVICE PROVIDER
// =============================================================================

/// Provides the AudiobookGroupingService for grouping audiobooks.
/// This service handles the logic for grouping audiobooks by metadata or directory.
final audiobookGroupingServiceProvider = Provider<AudiobookGroupingService>((
  ref,
) {
  return AudiobookGroupingService();
});

// =============================================================================
// LIBRARY REPOSITORY PROVIDER
// =============================================================================

/// Provides the Library Repository implementation.
/// This handles all library operations and depends on the audiobook datasource.
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  // Watch the future provider and get the actual datasource
  final localDatasource = ref.watch(audiobookLocalDatasourceProvider).value;
  final remoteDatasource = ref.watch(libraryRemoteDatasourceProvider);

  if (localDatasource == null) {
    throw Exception('Audiobook local datasource not initialized');
  }

  return LibraryRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
  );
});

// =============================================================================
// SCAN LIBRARY USE CASE PROVIDER
// =============================================================================

/// Provides ScanLibraryUseCaseImpl for orchestrating the complete scanning workflow.
///
/// This use case:
/// - Receives both datasources as clean dependencies
/// - Extracts metadata from audio files
/// - Saves audiobooks to the database
/// - Returns scan results with errors collected per file
///
/// The workflow is:
/// 1. Extract metadata from all audio files in a directory
/// 2. Save successfully extracted audiobooks to Isar
/// 3. Return results including any per-file errors
final scanLibraryUseCaseProvider = FutureProvider<ScanLibraryUseCaseImpl>((
  ref,
) async {
  final extractor = ref.watch(metadataExtractionDatasourceProvider);
  final localDatasource = await ref.watch(
    audiobookLocalDatasourceProvider.future,
  );

  return ScanLibraryUseCaseImpl(
    extractor: extractor,
    localDatasource: localDatasource,
  );
});
