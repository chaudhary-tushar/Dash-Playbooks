/// Dependency Injection configuration for Flutbook using Riverpod.
///
/// This file wires all application dependencies in the correct order:
/// 1. DatabaseService - Initializes Isar database
/// 2. AudioInitializationService - Initializes audio services
/// 3. Datasources - Depend on DatabaseService
/// 4. Use Cases - Depend on datasources
/// 5. Repositories - Depend on datasources and use cases
/// 6. Notifiers - Depend on repositories
library;

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/core/services/audio_initialization_service.dart';
import 'package:flutbook/core/services/database_service.dart';
import 'package:flutbook/core/services/json_storage_service.dart';
import 'package:flutbook/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:flutbook/features/auth/data/datasources/user_profile_datasource.dart';
import 'package:flutbook/features/auth/data/repositories/user_repository_impl.dart';
import 'package:flutbook/features/auth/data/services/user_profile_service.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/anonymous_login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/authenticate_usecase.dart';
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
import 'package:flutbook/features/player/data/datasources/audio_effects_ds.dart';
import 'package:flutbook/features/player/data/datasources/bookmark_local_ds.dart';
import 'package:flutbook/features/player/data/datasources/playback_local_ds.dart';
import 'package:flutbook/features/player/data/datasources/queue_local_ds.dart';
import 'package:flutbook/features/player/data/datasources/remote/supabase_playback_sync.dart';
import 'package:flutbook/features/player/data/repositories/audio_effects_repository_impl.dart';
import 'package:flutbook/features/player/data/repositories/bookmark_repository_impl.dart';
import 'package:flutbook/features/player/data/repositories/playback_repository_impl.dart';
import 'package:flutbook/features/player/data/repositories/queue_repository_impl.dart';
import 'package:flutbook/features/player/domain/usecases/audio_effects_usecase.dart';
import 'package:flutbook/features/player/domain/usecases/create_bookmark_usecase.dart';
import 'package:flutbook/features/player/domain/usecases/get_bookmarks_usecase.dart';
import 'package:flutbook/features/player/domain/usecases/manage_queue_usecase.dart';
import 'package:flutbook/features/settings/data/datasources/preferences_datasource.dart';
import 'package:flutbook/features/sync/data/datasources/offline_queue_local_ds.dart';
import 'package:flutbook/features/sync/data/datasources/supabase_backup_datasource.dart';
import 'package:flutbook/features/sync/data/datasources/supabase_reading_list_datasource.dart';
import 'package:flutbook/features/sync/data/repositories/backup_repository_impl.dart';
import 'package:flutbook/features/sync/data/repositories/library_sync_repository_impl.dart';
import 'package:flutbook/features/sync/data/repositories/offline_queue_repository_impl.dart';
import 'package:flutbook/features/sync/data/repositories/playback_sync_repository_impl.dart';
import 'package:flutbook/features/sync/data/repositories/reading_list_sync_repository_impl.dart';
import 'package:flutbook/features/sync/domain/usecases/sync_library_usecase.dart';
import 'package:flutbook/features/sync/domain/usecases/sync_playback_position_usecase.dart';
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

  // Validate that database is properly initialized
  if (!service.isar.isOpen) {
    throw UninitializedDatasourceException(
      'Database initialization failed - Isar database not open',
    );
  }

  return service;
});

// =============================================================================
// AUDIO INITIALIZATION SERVICE PROVIDER
// =============================================================================

/// Provides the AudioInitializationService for early audio service initialization.
/// This service initializes audio session management, background audio processing,
/// and other audio-related services early in the app lifecycle.
final audioInitializationServiceProvider = FutureProvider<void>((ref) async {
  await AudioInitializationService.initialize();
  return;
});

// =============================================================================
// USER PROFILE DATASOURCE PROVIDER
// =============================================================================

/// Provides the UserProfileDatasource for ISAR database operations.
/// This datasource handles all UserProfileModel operations with the ISAR database.
/// This must be initialized after the DatabaseService is available.
final FutureProvider<UserProfileDatasource> userProfileDatasourceProvider = FutureProvider((
  ref,
) async {
  // Wait for database service to be initialized
  final databaseService = await ref.watch(databaseServiceProvider.future);

  return UserProfileDatasource(databaseService: databaseService);
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
final metadataExtractionDatasourceProvider = Provider<MetadataExtractionDatasource>((ref) {
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
final audiobookLocalDatasourceProvider = FutureProvider<AudiobookLocalDatasource>((ref) async {
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
/// This provider explicitly depends on databaseServiceProvider to ensure proper initialization order.
final playbackLocalDatasourceProvider = FutureProvider<PlaybackLocalDatasource>(
  (ref) async {
    // Explicitly wait for database service to be initialized
    // This ensures the database is ready before creating the datasource
    final databaseService = await ref.watch(databaseServiceProvider.future);

    // Validate that the database is properly initialized
    if (!databaseService.isar.isOpen) {
      throw UninitializedDatasourceException(
        'Database is not open for playback operations',
      );
    }

    return PlaybackLocalDatasource(databaseService.isar);
  },
);

// =============================================================================
// BOOKMARK LOCAL DATASOURCE PROVIDER
// =============================================================================

/// Provides BookmarkLocalDatasource for database operations.
///
/// This datasource:
/// - Stores and retrieves bookmarks from Isar
/// - Queries the database for bookmark-related data
///
/// **Important**: The DatabaseService must be initialized before this datasource is used.
/// This provider explicitly depends on databaseServiceProvider to ensure proper initialization order.
final bookmarkLocalDatasourceProvider = FutureProvider<BookmarkLocalDatasource>(
  (ref) async {
    // Explicitly wait for database service to be initialized
    // This ensures the database is ready before creating the datasource
    final databaseService = await ref.watch(databaseServiceProvider.future);

    // Validate that the database is properly initialized
    if (!databaseService.isar.isOpen) {
      throw UninitializedDatasourceException(
        'Database is not open for bookmark operations',
      );
    }

    return BookmarkLocalDatasource(databaseService.isar);
  },
);

// =============================================================================
// QUEUE LOCAL DATASOURCE PROVIDER
// =============================================================================

/// Provides QueueLocalDatasource for database operations.
///
/// This datasource:
/// - Stores and retrieves queues from Isar
/// - Queries the database for queue-related data
///
/// **Important**: The DatabaseService must be initialized before this datasource is used.
/// This provider explicitly depends on databaseServiceProvider to ensure proper initialization order.
final queueLocalDatasourceProvider = FutureProvider<QueueLocalDatasource>(
  (ref) async {
    // Explicitly wait for database service to be initialized
    // This ensures the database is ready before creating the datasource
    final databaseService = await ref.watch(databaseServiceProvider.future);

    // Validate that the database is properly initialized
    if (!databaseService.isar.isOpen) {
      throw UninitializedDatasourceException(
        'Database is not open for queue operations',
      );
    }

    return QueueLocalDatasource(databaseService.isar);
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
/// Provides PlaybackRepositoryImpl for playback operations.
///
/// This repository:
/// - Manages playback sessions and history
/// - Handles local and remote synchronization
/// - Provides graceful degradation when datasources are not available
/// - Implements retry mechanisms for failed initializations
///
/// **Initialization Order**:
/// 1. DatabaseService (must be initialized first)
/// 2. PlaybackLocalDatasource (depends on DatabaseService)
/// 3. PlaybackRemoteDatasource (optional, for authenticated users)
/// 4. PlaybackRepositoryImpl (depends on all above)
final playbackRepositoryProvider = FutureProvider<PlaybackRepositoryImpl>((
  ref,
) async {
  const maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      // Step 1: Ensure database service is initialized first
      // This is the most critical dependency for all playback operations
      final databaseService = await ref.watch(databaseServiceProvider.future);

      // Validate database is properly initialized
      if (!databaseService.isar.isOpen) {
        throw UninitializedDatasourceException(
          'Database is not ready for playback repository',
        );
      }

      // Step 2: Wait for the local datasource to be initialized
      // This depends on the database service being ready
      final localDatasource = await ref.watch(
        playbackLocalDatasourceProvider.future,
      );

      // Step 3: Get remote datasource (may be null for anonymous users)
      // This doesn't depend on database initialization
      final remoteDatasource = ref.watch(playbackRemoteDatasourceProvider);

      // Validate that local datasource is properly initialized
      if (!localDatasource.isInitialized) {
        throw UninitializedDatasourceException(
          'Playback local datasource is not initialized',
        );
      }

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
// BOOKMARK REPOSITORY PROVIDER
// =============================================================================

/// Provides BookmarkRepositoryImpl for bookmark operations.
///
/// This repository:
/// - Manages bookmark creation, retrieval, and deletion
/// - Handles local storage of bookmarks
/// - Provides graceful degradation when datasources are not available
/// - Implements retry mechanisms for failed initializations
///
/// **Initialization Order**:
/// 1. DatabaseService (must be initialized first)
/// 2. BookmarkLocalDatasource (depends on DatabaseService)
/// 3. BookmarkRepositoryImpl (depends on all above)
final bookmarkRepositoryProvider = FutureProvider<BookmarkRepositoryImpl>((
  ref,
) async {
  const maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      // Step 1: Ensure database service is initialized first
      // This is the most critical dependency for all bookmark operations
      final databaseService = await ref.watch(databaseServiceProvider.future);

      // Validate database is properly initialized
      if (!databaseService.isar.isOpen) {
        throw UninitializedDatasourceException(
          'Database is not ready for bookmark repository',
        );
      }

      // Step 2: Wait for the local datasource to be initialized
      // This depends on the database service being ready
      final localDatasource = await ref.watch(
        bookmarkLocalDatasourceProvider.future,
      );

      // Validate that local datasource is properly initialized
      if (!localDatasource.isInitialized) {
        throw UninitializedDatasourceException(
          'Bookmark local datasource is not initialized',
        );
      }

      return BookmarkRepositoryImpl(
        localDatasource: localDatasource,
      );
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        throw UninitializedDatasourceException(
          'Failed to initialize BookmarkRepository after $maxRetries attempts: ${ErrorHandler.handleException(e)}',
        );
      }

      // Wait before retrying
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  // This line should never be reached due to the retry logic above
  throw UninitializedDatasourceException(
    'BookmarkRepository initialization failed',
  );
});

// =============================================================================
// QUEUE REPOSITORY PROVIDER
// =============================================================================

/// Provides QueueRepositoryImpl for queue operations.
///
/// This repository:
/// - Manages queue creation, retrieval, and deletion
/// - Handles local storage of queues
/// - Provides graceful degradation when datasources are not available
/// - Implements retry mechanisms for failed initializations
///
/// **Initialization Order**:
/// 1. DatabaseService (must be initialized first)
/// 2. QueueLocalDatasource (depends on DatabaseService)
/// 3. QueueRepositoryImpl (depends on all above)
final queueRepositoryProvider = FutureProvider<QueueRepositoryImpl>((
  ref,
) async {
  const maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      // Step 1: Ensure database service is initialized first
      // This is the most critical dependency for all queue operations
      final databaseService = await ref.watch(databaseServiceProvider.future);

      // Validate database is properly initialized
      if (!databaseService.isar.isOpen) {
        throw UninitializedDatasourceException(
          'Database is not ready for queue repository',
        );
      }

      // Step 2: Wait for the local datasource to be initialized
      // This depends on the database service being ready
      final localDatasource = await ref.watch(
        queueLocalDatasourceProvider.future,
      );

      // Validate that local datasource is properly initialized
      if (!localDatasource.isInitialized) {
        throw UninitializedDatasourceException(
          'Queue local datasource is not initialized',
        );
      }

      return QueueRepositoryImpl(
        localDatasource: localDatasource,
      );
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        throw UninitializedDatasourceException(
          'Failed to initialize QueueRepository after $maxRetries attempts: ${ErrorHandler.handleException(e)}',
        );
      }

      // Wait before retrying
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  // This line should never be reached due to the retry logic above
  throw UninitializedDatasourceException(
    'QueueRepository initialization failed',
  );
});

/// Provides a provider that checks if playback repository is in error state
final playbackRepositoryErrorProvider = Provider<bool>((ref) {
  final playbackRepoAsync = ref.watch(playbackRepositoryProvider);

  return playbackRepoAsync.when(
    data: (_) => false, // No error if data is available
    loading: () => false, // No error while loading
    error: (error, stack) => true, // Error state detected
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

/// Provides the UserProfileService for user profile operations.
/// This handles user profile persistence to ISAR database.
final userProfileServiceProvider = FutureProvider<UserProfileService>((
  ref,
) async {
  // Wait for database service to be initialized
  final databaseService = await ref.watch(databaseServiceProvider.future);

  return UserProfileService(databaseService: databaseService);
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
///
/// **Initialization Order**:
/// 1. DatabaseService (must be initialized first)
/// 2. UserProfileService (depends on DatabaseService)
/// 3. UserRepositoryImpl (depends on UserProfileService)
final userRepositoryProvider = FutureProvider<UserRepository>((ref) async {
  const maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      // Step 1: Ensure database service is initialized first
      final databaseService = await ref.watch(databaseServiceProvider.future);

      // Validate database is properly initialized
      if (!databaseService.isar.isOpen) {
        throw UninitializedDatasourceException(
          'Database is not ready for user repository',
        );
      }

      // Step 2: Wait for the user profile service to be initialized
      final userProfileService = await ref.watch(
        userProfileServiceProvider.future,
      );

      return UserRepositoryImpl(
        authDatasource: ref.watch(supabaseAuthDatasourceProvider),
        syncDatasource: ref.watch(libraryRemoteDatasourceProvider),
        playbackRemoteDatasource: ref.watch(playbackRemoteDatasourceProvider),
        preferencesDatasource: ref.watch(preferencesDatasourceProvider),
        userProfileService: userProfileService,
      );
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        throw UninitializedDatasourceException(
          'Failed to initialize UserRepository after $maxRetries attempts: ${ErrorHandler.handleException(e)}',
        );
      }

      // Wait before retrying
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  // This line should never be reached due to the retry logic above
  throw UninitializedDatasourceException(
    'UserRepository initialization failed',
  );
});

/// Provides the Login usecase.
/// This depends on the user repository.
final loginUsecaseProvider = FutureProvider<LoginUsecase>((ref) async {
  // Wait for the user repository to be ready
  final userRepository = await ref.watch(userRepositoryProvider.future);

  return LoginUsecase(userRepository);
});

/// Provides the Anonymous Login usecase.
/// This depends on the user repository.
final anonymousLoginUsecaseProvider = FutureProvider<AnonymousLoginUsecase>((ref) async {
  // Wait for the user repository to be ready
  final userRepository = await ref.watch(userRepositoryProvider.future);

  return AnonymousLoginUsecase(userRepository);
});

/// Provides the Google Sign-in usecase.
/// This depends on the user repository.
final googleSigninUsecaseProvider = FutureProvider<GoogleSigninUsecase>((ref) async {
  // Wait for the user repository to be ready
  final userRepository = await ref.watch(userRepositoryProvider.future);

  return GoogleSigninUsecase(userRepository);
});

/// Provides the Logout usecase.
/// This depends on the user repository.
final logoutUsecaseProvider = FutureProvider<LogoutUsecase>((ref) async {
  // Wait for the user repository to be ready
  final userRepository = await ref.watch(userRepositoryProvider.future);

  return LogoutUsecase(userRepository);
});

/// Provides the Get Current User usecase.
/// This depends on the user repository.
final getCurrentUserUsecaseProvider = FutureProvider<GetCurrentUserUsecase>((ref) async {
  // Wait for the user repository to be initialized
  final userRepository = await ref.watch(userRepositoryProvider.future);

  return GetCurrentUserUsecase(userRepository);
});

/// Provides the Signup usecase.
/// This depends on the user repository.
final signupUsecaseProvider = FutureProvider<SignupUsecase>((ref) async {
  // Wait for the user repository to be ready
  final userRepository = await ref.watch(userRepositoryProvider.future);

  return SignupUsecase(userRepository);
});

/// Provides the Authenticate usecase (unified login/signup).
/// This depends on the user repository.
final authenticateUsecaseProvider = FutureProvider<AuthenticateUsecase>((ref) async {
  // Wait for the user repository to be ready
  final userRepository = await ref.watch(userRepositoryProvider.future);

  return AuthenticateUsecase(userRepository);
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
///
/// **Initialization Order**:
/// 1. DatabaseService (must be initialized first)
/// 2. AudiobookLocalDatasource (depends on DatabaseService)
/// 3. LibraryRemoteDatasource (optional, for authenticated users)
/// 4. LibraryRepositoryImpl (depends on all above)
final libraryRepositoryProvider = FutureProvider<LibraryRepository>((
  ref,
) async {
  const maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      // Step 1: Ensure database service is initialized first
      // This is the most critical dependency for all library operations
      final databaseService = await ref.watch(databaseServiceProvider.future);

      // Validate database is properly initialized
      if (!databaseService.isar.isOpen) {
        throw UninitializedDatasourceException(
          'Database is not ready for library repository',
        );
      }

      // Step 2: Wait for the local datasource to be initialized
      // This depends on the database service being ready
      final localDatasource = await ref.watch(
        audiobookLocalDatasourceProvider.future,
      );

      // Step 3: Get remote datasource (may be null for anonymous users)
      // This doesn't depend on database initialization
      final remoteDatasource = ref.watch(libraryRemoteDatasourceProvider);

      // Validate that local datasource is properly initialized
      if (!localDatasource.isInitialized) {
        throw UninitializedDatasourceException(
          'Library local datasource is not initialized',
        );
      }

      return LibraryRepositoryImpl(
        localDatasource: localDatasource,
        remoteDatasource: remoteDatasource,
      );
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        throw UninitializedDatasourceException(
          'Failed to initialize LibraryRepository after $maxRetries attempts: ${ErrorHandler.handleException(e)}',
        );
      }

      // Wait before retrying
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  // This line should never be reached due to the retry logic above
  throw UninitializedDatasourceException(
    'LibraryRepository initialization failed',
  );
});

/// Provides a provider that checks if library repository is in error state
final libraryRepositoryErrorProvider = Provider<bool>((ref) {
  final libraryRepoAsync = ref.watch(libraryRepositoryProvider);

  return libraryRepoAsync.when(
    data: (_) => false, // No error if data is available
    loading: () => false, // No error while loading
    error: (error, stack) => true, // Error state detected
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

// =============================================================================
// BOOKMARK USE CASE PROVIDERS
// =============================================================================

/// Provides CreateBookmarkUsecase for creating bookmarks.
/// This depends on the bookmark repository.
final createBookmarkUsecaseProvider = Provider<CreateBookmarkUsecase>((ref) {
  // Handle the async bookmark repository properly
  final bookmarkRepoAsync = ref.watch(bookmarkRepositoryProvider);
  final bookmarkRepository = bookmarkRepoAsync.whenOrNull(
    data: (repo) => repo,
    loading: () => null,
    error: (error, stack) => null,
  );

  if (bookmarkRepository == null) {
    throw UninitializedDatasourceException(
      'Bookmark repository not initialized',
    );
  }

  return CreateBookmarkUsecase(bookmarkRepository);
});

/// Provides GetBookmarksUsecase for retrieving bookmarks.
/// This depends on the bookmark repository.
final getBookmarksUsecaseProvider = Provider<GetBookmarksUsecase>((ref) {
  // Handle the async bookmark repository properly
  final bookmarkRepoAsync = ref.watch(bookmarkRepositoryProvider);
  final bookmarkRepository = bookmarkRepoAsync.whenOrNull(
    data: (repo) => repo,
    loading: () => null,
    error: (error, stack) => null,
  );

  if (bookmarkRepository == null) {
    throw UninitializedDatasourceException(
      'Bookmark repository not initialized',
    );
  }

  return GetBookmarksUsecase(bookmarkRepository);
});

// =============================================================================
// QUEUE USE CASE PROVIDERS
// =============================================================================

/// Provides ManageQueueUsecase for queue operations.
/// This depends on the queue repository.
final manageQueueUsecaseProvider = Provider<ManageQueueUsecase>((ref) {
  // Handle the async queue repository properly
  final queueRepoAsync = ref.watch(queueRepositoryProvider);
  final queueRepository = queueRepoAsync.whenOrNull(
    data: (repo) => repo,
    loading: () => null,
    error: (error, stack) => null,
  );

  if (queueRepository == null) {
    throw UninitializedDatasourceException(
      'Queue repository not initialized',
    );
  }

  return ManageQueueUsecase(queueRepository);
});

// =============================================================================
// AUDIO EFFECTS DATASOURCE PROVIDER
// =============================================================================

/// Provides AudioEffectsDatasource for database operations.
///
/// This datasource:
/// - Stores and retrieves audio effects from Isar
/// - Queries the database for audio effects data
///
/// **Important**: The DatabaseService must be initialized before this datasource is used.
/// This provider explicitly depends on databaseServiceProvider to ensure proper initialization order.
final audioEffectsDatasourceProvider = FutureProvider<AudioEffectsDatasource>(
  (ref) async {
    // Explicitly wait for database service to be initialized
    // This ensures the database is ready before creating the datasource
    final databaseService = await ref.watch(databaseServiceProvider.future);

    // Validate that the database is properly initialized
    if (!databaseService.isar.isOpen) {
      throw UninitializedDatasourceException(
        'Database is not open for audio effects operations',
      );
    }

    return AudioEffectsDatasource(databaseService.isar);
  },
);

// =============================================================================
// AUDIO EFFECTS REPOSITORY PROVIDER
// =============================================================================

/// Provides AudioEffectsRepositoryImpl for audio effects operations.
///
/// This repository:
/// - Manages audio effect creation, retrieval, and deletion
/// - Handles local storage of audio effects
/// - Provides graceful degradation when datasources are not available
/// - Implements retry mechanisms for failed initializations
///
/// **Initialization Order**:
/// 1. DatabaseService (must be initialized first)
/// 2. AudioEffectsDatasource (depends on DatabaseService)
/// 3. AudioEffectsRepositoryImpl (depends on all above)
final audioEffectsRepositoryProvider = FutureProvider<AudioEffectsRepositoryImpl>((
  ref,
) async {
  const maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      // Step 1: Ensure database service is initialized first
      // This is the most critical dependency for all audio effects operations
      final databaseService = await ref.watch(databaseServiceProvider.future);

      // Validate database is properly initialized
      if (!databaseService.isar.isOpen) {
        throw UninitializedDatasourceException(
          'Database is not ready for audio effects repository',
        );
      }

      // Step 2: Wait for the local datasource to be initialized
      // This depends on the database service being ready
      final localDatasource = await ref.watch(
        audioEffectsDatasourceProvider.future,
      );

      // Validate that local datasource is properly initialized
      if (!localDatasource.isInitialized) {
        throw UninitializedDatasourceException(
          'Audio effects local datasource is not initialized',
        );
      }

      return AudioEffectsRepositoryImpl(
        localDatasource: localDatasource,
      );
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        throw UninitializedDatasourceException(
          'Failed to initialize AudioEffectsRepository after $maxRetries attempts: ${ErrorHandler.handleException(e)}',
        );
      }

      // Wait before retrying
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  // This line should never be reached due to the retry logic above
  throw UninitializedDatasourceException(
    'AudioEffectsRepository initialization failed',
  );
});

// =============================================================================
// AUDIO EFFECTS USE CASE PROVIDERS
// =============================================================================

/// Provides AudioEffectsUsecase for audio effects operations.
/// This depends on the audio effects repository.
final audioEffectsUsecaseProvider = Provider<AudioEffectsUsecase>((ref) {
  // Handle the async audio effects repository properly
  final audioEffectsRepoAsync = ref.watch(audioEffectsRepositoryProvider);
  final audioEffectsRepository = audioEffectsRepoAsync.whenOrNull(
    data: (repo) => repo,
    loading: () => null,
    error: (error, stack) => null,
  );

  if (audioEffectsRepository == null) {
    throw UninitializedDatasourceException(
      'Audio effects repository not initialized',
    );
  }

  return AudioEffectsUsecase(audioEffectsRepository);
});

// =============================================================================
// LIBRARY SYNC PROVIDERS (PHASE 7)
// =============================================================================

/// Provides the LibrarySyncRepositoryImpl for library synchronization.
///
/// This repository handles bidirectional sync between local Isar database
/// and remote Supabase database with conflict resolution.
final librarySyncRepositoryProvider = FutureProvider<LibrarySyncRepositoryImpl>(
  (ref) async {
    final localDatasource = await ref.watch(
      audiobookLocalDatasourceProvider.future,
    );
    final remoteDatasource = ref.watch(libraryRemoteDatasourceProvider);

    return LibrarySyncRepositoryImpl(
      localDatasource: localDatasource,
      remoteDatasource: remoteDatasource,
    );
  },
);

/// Provides the SyncLibraryUseCase for library synchronization.
///
/// This use case orchestrates the library sync process and returns
/// sync results with statistics.
final syncLibraryUseCaseProvider = Provider<SyncLibraryUseCase>((ref) {
  final syncRepoAsync = ref.watch(librarySyncRepositoryProvider);
  final syncRepository = syncRepoAsync.whenOrNull(
    data: (repo) => repo,
    loading: () => null,
    error: (error, stack) => null,
  );

  if (syncRepository == null) {
    throw UninitializedDatasourceException(
      'Library sync repository not initialized',
    );
  }

  return SyncLibraryUseCase(repository: syncRepository);
});

// =============================================================================
// PLAYBACK POSITION SYNC PROVIDERS (PHASE 7, TASK 7.2)
// =============================================================================

/// Provides the SupabasePlaybackDatasource for remote playback sync.
///
/// This datasource handles all remote synchronization operations
/// with Supabase for playback position data.
final perBookSpeedEnabledProvider = NotifierProvider<PerBookSpeedNotifier, bool>(
  PerBookSpeedNotifier.new,
);

class PerBookSpeedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setEnabled(bool enabled) => state = enabled;
}

/// Provides the PlaybackSyncRepositoryImpl for playback position synchronization.
///
/// This repository handles bidirectional sync between local Isar database
/// and remote Supabase database with conflict resolution.
final playbackSyncRepositoryProvider = FutureProvider<PlaybackSyncRepositoryImpl>(
  (ref) async {
    final localDatasource = await ref.watch(
      playbackLocalDatasourceProvider.future,
    );
    final remoteDatasource = ref.watch(playbackRemoteDatasourceProvider);

    return PlaybackSyncRepositoryImpl(
      localDatasource: localDatasource,
      remoteDatasource: remoteDatasource,
    );
  },
);

/// Provides the SyncPlaybackPositionUseCase for playback position synchronization.
///
/// This use case orchestrates the playback position sync process and returns
/// sync results with statistics.
final syncPlaybackPositionUseCaseProvider = Provider<SyncPlaybackPositionUseCase>((ref) {
  final syncRepoAsync = ref.watch(playbackSyncRepositoryProvider);
  final syncRepository = syncRepoAsync.whenOrNull(
    data: (repo) => repo,
    loading: () => null,
    error: (error, stack) => null,
  );

  if (syncRepository == null) {
    throw UninitializedDatasourceException(
      'Playback sync repository not initialized',
    );
  }

  return SyncPlaybackPositionUseCase(repository: syncRepository);
});

// =============================================================================
// READING LIST SYNC PROVIDERS (PHASE 7, TASK 7.3)
// =============================================================================

/// Provides the SupabaseReadingListDatasource for reading list sync.
///
/// This datasource handles all remote operations for reading lists.
final supabaseReadingListDatasourceProvider = Provider<SupabaseReadingListDatasource>((
  ref,
) {
  final supabase = Supabase.instance.client;
  final configProvider = ref.watch(appConfigProvider);

  return SupabaseReadingListDatasource(
    supabase: supabase,
    configProvider: configProvider,
  );
});

/// Provides the ReadingListSyncRepositoryImpl for reading list management.
///
/// This repository handles reading list CRUD operations with sync.
final readingListSyncRepositoryProvider = FutureProvider<ReadingListSyncRepositoryImpl>(
  (ref) async {
    final remoteDatasource = ref.watch(supabaseReadingListDatasourceProvider);

    return ReadingListSyncRepositoryImpl(
      remoteDatasource: remoteDatasource,
    );
  },
);

// =============================================================================
// BACKUP PROVIDERS (PHASE 7, TASK 7.4)
// =============================================================================

/// Provides the SupabaseBackupDatasource for backup operations.
final supabaseBackupDatasourceProvider = Provider<SupabaseBackupDatasource>((
  ref,
) {
  final supabase = Supabase.instance.client;
  final ConfigProvider configProvider = ref.watch(appConfigProvider);

  return SupabaseBackupDatasource(
    supabase: supabase,
    configProvider: configProvider,
  );
});

/// Provides the BackupRepositoryImpl for backup operations.
final backupRepositoryProvider = FutureProvider<BackupRepositoryImpl>((ref) async {
  final backupDatasource = ref.watch(supabaseBackupDatasourceProvider);
  // Note: In a real implementation, these would be fetched from the database
  return BackupRepositoryImpl(
    backupDatasource: backupDatasource,
    audiobooks: [],
    playbackSessions: [],
    readingLists: [],
  );
});

// =============================================================================
// OFFLINE QUEUE PROVIDERS (PHASE 7, TASK 7.5)
// =============================================================================

/// Provides the OfflineQueueLocalDatasource for queue storage.
final offlineQueueLocalDatasourceProvider = FutureProvider<OfflineQueueLocalDatasource>(
  (ref) async {
    // Get the database service which provides the Isar instance
    final databaseService = await ref.watch(databaseServiceProvider.future);

    // Validate database is open
    if (!databaseService.isar.isOpen) {
      throw UninitializedDatasourceException(
        'Database is not open for offline queue operations',
      );
    }

    return OfflineQueueLocalDatasource();
  },
);

/// Provides the OfflineQueueRepositoryImpl for queue management.
final offlineQueueRepositoryProvider = FutureProvider<OfflineQueueRepositoryImpl>(
  (ref) async {
    final localDatasource = await ref.watch(offlineQueueLocalDatasourceProvider.future);

    return OfflineQueueRepositoryImpl(
      localDatasource: localDatasource,
    );
  },
);
