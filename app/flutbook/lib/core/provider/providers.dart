/// Dependency Injection configuration for Flutbook using Riverpod.
///
/// This file wires all application dependencies in the correct order:
/// 1. DatabaseService - Initializes Isar database
/// 2. Datasources - Depend on DatabaseService
/// 3. Use Cases - Depend on datasources
/// 4. Repositories - Depend on datasources and use cases
library;

import 'package:flutbook/core/services/database_service.dart';
import 'package:flutbook/core/services/json_storage_service.dart';
import 'package:flutbook/features/directory_selection/data/datasources/metadat_extractor_ds.dart';
import 'package:flutbook/features/directory_selection/domain/usecases/scan_library_usecase.dart';
import 'package:flutbook/features/library/data/datasources/audiobook_local_ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutbook/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:flutbook/features/auth/data/repositories/user_repository_impl.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/anonymous_login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutbook/features/settings/data/datasources/preferences_datasource.dart';
import 'package:flutbook/features/library/data/datasources/remote/firebase_library_sync.dart';
import 'package:flutbook/features/player/data/datasources/remote/firebase_playback_sync.dart';

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
// SCAN LIBRARY USE CASE PROVIDER
// =============================================================================

// =============================================================================
// AUTHENTICATION PROVIDERS
// =============================================================================

/// Provides the Firebase authentication datasource.
/// This handles all Firebase authentication operations.
final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource();
});

/// Provides the Preferences datasource.
/// This handles user preferences and settings storage.
final preferencesDatasourceProvider = Provider<PreferencesDatasource>((ref) {
  return PreferencesDatasource();
});

/// Provides the Library Remote datasource.
/// This handles remote library operations with Firebase.
final libraryRemoteDatasourceProvider = Provider<LibraryRemoteDatasource>((ref) {
  return LibraryRemoteDatasource();
});

/// Provides the Playback Remote datasource.
/// This handles remote playback progress operations with Firebase.
final playbackRemoteDatasourceProvider = Provider<PlaybackRemoteDatasource>((ref) {
  return PlaybackRemoteDatasource();
});

/// Provides the User Repository implementation.
/// This depends on the auth datasource and other remote datasources.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    authDatasource: ref.watch(firebaseAuthDatasourceProvider),
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
final scanLibraryUseCaseProvider = FutureProvider<ScanLibraryUseCaseImpl>((ref) async {
  final extractor = ref.watch(metadataExtractionDatasourceProvider);
  final localDatasource = await ref.watch(audiobookLocalDatasourceProvider.future);

  return ScanLibraryUseCaseImpl(
    extractor: extractor,
    localDatasource: localDatasource,
  );
});
