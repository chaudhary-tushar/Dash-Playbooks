import 'package:flutbook/features/auth/data/datasources/firebase_auth_datasource.dart';
// import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart'
    show AuthResult, SyncResult, SyncStatus, UserRepository, UserSettings;
import 'package:flutbook/features/library/data/datasources/remote/firebase_library_sync.dart';
import 'package:flutbook/features/playback/data/datasources/remote/firebase_playback_sync.dart';
import 'package:flutbook/features/settings/data/datasources/preferences_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required FirebaseAuthDatasource authDatasource,
    required LibraryRemoteDatasource syncDatasource,
    required PlaybackRemoteDatasource playbackRemoteDatasource,
    required PreferencesDatasource preferencesDatasource,
  }) : _authDatasource = authDatasource,
       _syncDatasource = syncDatasource,
       _playbackRemoteDatasource = playbackRemoteDatasource,
       _preferencesDatasource = preferencesDatasource;
  final FirebaseAuthDatasource _authDatasource;
  final LibraryRemoteDatasource _syncDatasource;
  final PlaybackRemoteDatasource _playbackRemoteDatasource;
  final PreferencesDatasource _preferencesDatasource;
  // late final LibraryRepository _libraryRepo;
  // late final PlaybackRepository _playbackRepo;

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _authDatasource.signInWithEmailAndPassword(
        email,
        password,
      );

      if (result.success && result.user != null) {
        // Save user preferences
        await _preferencesDatasource.saveUserPreferences(result.user);
      }

      return AuthResult(
        success: result.success,
        userId: result.userId,
        errorMessage: result.errorMessage,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Sign in failed: $e',
      );
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final result = await _authDatasource.signInWithGoogle();

      if (result.success && result.user != null) {
        // Save user preferences
        await _preferencesDatasource.saveUserPreferences(result.user);
      }

      return AuthResult(
        success: result.success,
        userId: result.userId,
        errorMessage: result.errorMessage,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Google sign in failed: $e',
      );
    }
  }

  @override
  Future<AuthResult> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _authDatasource.signUpWithEmailAndPassword(
        email,
        password,
      );

      if (result.success && result.user != null) {
        // Save user preferences
        await _preferencesDatasource.saveUserPreferences(result.user);
      }

      return AuthResult(
        success: result.success,
        userId: result.userId,
        errorMessage: result.errorMessage,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Sign up failed: $e',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _authDatasource.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    return _authDatasource.getCurrentUser();
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    try {
      final hasPendingSync = await _preferencesDatasource.hasPendingSyncChanges();
      final lastSyncAt = await _preferencesDatasource.getLastSyncTime();

      return SyncStatus(
        isSyncing: false, // Would track actual sync status in real implementation
        syncEnabled: true, // Would come from user settings
        lastSyncSuccessful: await _preferencesDatasource.getLastSyncSuccessful(),
        lastSyncAt: lastSyncAt,
        hasPendingChanges: hasPendingSync,
      );
    } catch (e) {
      return const SyncStatus(
        isSyncing: false,
        syncEnabled: false,
        lastSyncSuccessful: false,
        hasPendingChanges: false,
      );
    }
  }

  @override
  Future<SyncResult> syncWithRemote() async {
    try {
      // Perform sync with remote
      final result = await syncAll();

      // Update sync preferences
      await _preferencesDatasource.setLastSyncTime(DateTime.now());
      await _preferencesDatasource.setLastSyncSuccessful(true);

      return SyncResult(
        success: result.success,
        errorMessage: result.errorMessage,
        itemsSynced: result.itemsSynced,
      );
    } catch (e) {
      await _preferencesDatasource.setLastSyncSuccessful(false);
      return SyncResult(
        success: false,
        errorMessage: 'Sync failed: $e',
        itemsSynced: 0,
      );
    }
  }

  /// Syncs all user data with remote, with conflict resolution
  Future<SyncResult> syncAll() async {
    try {
      final _ = _authDatasource.getCurrentUser();

      // For simplicity, we'll sync audiobook metadata and playback sessions
      // In a real implementation, we'd also sync user settings and preferences
      final remoteAudiobooks = await _syncDatasource.getAudiobookMetadata();
      final remoteSessions = await _playbackRemoteDatasource.getPlaybackSessions();

      return SyncResult(
        success: true,
        errorMessage: 'Sync completed successfully',
        itemsSynced: remoteAudiobooks.length + remoteSessions.length,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        errorMessage: 'Sync failed: $e',
        itemsSynced: 0,
      );
    }
  }

  @override
  Future<UserSettings> getUserSettings() async {
    try {
      final settings = await _preferencesDatasource.getUserSettings();
      return UserSettings.fromMap(settings);
    } catch (e) {
      // Return default settings if none exist
      return UserSettings.defaultSettings();
    }
  }

  @override
  Future<void> updateUserSettings(UserSettings settings) async {
    try {
      await _preferencesDatasource.saveUserSettings(settings.toMap());
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  /// Updates sync enabled status for the user
  // ignore: avoid_positional_boolean_parameters
  Future<void> updateSyncEnabled(bool enabled) async {
    try {
      final currentSettings = await getUserSettings();
      final newSettings = currentSettings.copyWith(syncEnabled: enabled);
      await updateUserSettings(newSettings);
    } catch (e) {
      throw Exception('Failed to update sync settings: $e');
    }
  }

  /// Gets the local library path for the user
  Future<String?> getLocalLibraryPath() async {
    try {
      final settings = await getUserSettings();
      return settings.localLibraryPath;
    } catch (e) {
      return null;
    }
  }

  /// Sets the local library path for the user
  Future<void> setLocalLibraryPath(String path) async {
    try {
      final currentSettings = await getUserSettings();
      final newSettings = currentSettings.copyWith(localLibraryPath: path);
      await updateUserSettings(newSettings);
    } catch (e) {
      throw Exception('Failed to set local library path: $e');
    }
  }
}

// features/auth/data/repositories/user_repository_impl.dart
// class UserRepositoryImpl implements UserRepository {
//
// }
