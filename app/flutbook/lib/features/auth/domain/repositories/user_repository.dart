// lib/features/auth/domain/repositories/user_repository.dart
import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/settings/domain/entities/sync_status.dart';
import 'package:flutbook/core/error/sync_result.dart';
import 'package:flutbook/features/settings/domain/entities/user_settings.dart';
// import 'package:isar_community/isar.dart';

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

  /// Signs in anonymously
  Future<AuthResult> anonymousSignIn();

  /// Streams authentication state changes
  Stream<UserProfile?> authStateChanges();

  /// Gets sync status
  Future<SyncStatus> getSyncStatus();

  /// Syncs local data with remote
  Future<SyncResult> syncWithRemote();

  /// Gets user settings
  Future<UserSettings> getUserSettings();

  /// Updates user settings
  Future<void> updateUserSettings(UserSettings settings);

  /// Updates remote data for a specific item
  Future<void> updateRemoteData(String itemId, dynamic data);

  /// Updates local data for a specific item
  Future<void> updateLocalData(String itemId, dynamic data);

  /// Updates remote progress for a specific item
  Future<void> updateRemoteProgress(String itemId, int position);

  /// Updates local progress for a specific item
  Future<void> updateLocalProgress(String itemId, int position);

  /// Deletes audiobook from remote storage
  Future<void> deleteRemoteAudiobook(String itemId);

  /// Deletes audiobook from local storage
  Future<void> deleteLocalAudiobook(String itemId);
}
