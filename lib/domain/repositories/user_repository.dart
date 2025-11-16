// lib/domain/repositories/user_repository.dart
import '../entities/user_profile.dart';

abstract class UserRepository {
  /// Attempts to authenticate user with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);

  /// Attempts to authenticate user with Google
  Future<AuthResult> signInWithGoogle();

  /// Creates a new user account
  Future<AuthResult> signUpWithEmailAndPassword(String email, String password);

  /// Signs out the current user
  Future<void> signOut();

  /// Gets the current authenticated user
  Future<UserProfile?> getCurrentUser();

  /// Gets sync status
  Future<SyncStatus> getSyncStatus();

  /// Syncs local data with remote
  Future<SyncResult> syncWithRemote();

  /// Gets user settings
  Future<UserSettings> getUserSettings();

  /// Updates user settings
  Future<void> updateUserSettings(UserSettings settings);
}

class AuthResult {
  final bool success;
  final String? userId;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    this.userId,
    this.errorMessage,
  });
}

class SyncStatus {
  final bool isSyncing;
  final bool syncEnabled;
  final bool lastSyncSuccessful;
  final DateTime? lastSyncAt;

  const SyncStatus({
    required this.isSyncing,
    required this.syncEnabled,
    required this.lastSyncSuccessful,
    this.lastSyncAt,
  });
}

class SyncResult {
  final bool success;
  final String? errorMessage;
  final int itemsSynced;

  const SyncResult({
    required this.success,
    this.errorMessage,
    required this.itemsSynced,
  });
}

class UserSettings {
  final String? preferredDirectoryPath;
  final double defaultPlaybackSpeed;
  final int defaultSkipInterval;
  final bool syncEnabled;
  final bool themeMode; // true for dark, false for light
  final String languageCode;

  const UserSettings({
    this.preferredDirectoryPath,
    required this.defaultPlaybackSpeed,
    required this.defaultSkipInterval,
    required this.syncEnabled,
    required this.themeMode,
    required this.languageCode,
  });
}