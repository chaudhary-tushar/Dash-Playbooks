// lib/features/auth/domain/repositories/user_repository.dart
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
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
  const AuthResult({
    required this.success,
    this.userId,
    this.errorMessage,
  });
  final bool success;
  final String? userId;
  final String? errorMessage;
}

class SyncStatus {
  const SyncStatus({
    required this.isSyncing,
    required this.syncEnabled,
    required this.lastSyncSuccessful,
    this.lastSyncAt,
    this.hasPendingChanges,
  });
  final bool isSyncing;
  final bool syncEnabled;
  final bool lastSyncSuccessful;
  final DateTime? lastSyncAt;
  final bool? hasPendingChanges;
}

class SyncResult {
  const SyncResult({
    required this.success,
    required this.itemsSynced,
    this.errorMessage,
  });
  final bool success;
  final String? errorMessage;
  final int itemsSynced;
}

class UserSettings {
  const UserSettings({
    required this.defaultPlaybackSpeed,
    required this.defaultSkipInterval,
    required this.syncEnabled,
    required this.themeMode,
    required this.languageCode,
    this.preferredDirectoryPath,
    this.localLibraryPath,
  });
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      defaultPlaybackSpeed: (map['defaultPlaybackSpeed'] as num?)?.toDouble() ?? 1.0,
      defaultSkipInterval: map['defaultSkipInterval'] as int? ?? 30,
      syncEnabled: map['syncEnabled'] as bool? ?? true,
      themeMode: map['themeMode'] as bool? ?? false,
      languageCode: map['languageCode'] as String? ?? 'en',
      preferredDirectoryPath: map['preferredDirectoryPath'] as String?,
      localLibraryPath: map['localLibraryPath'] as String?,
    );
  }

  final String? preferredDirectoryPath;
  final String? localLibraryPath;
  final double defaultPlaybackSpeed;
  final int defaultSkipInterval;
  final bool syncEnabled;
  final bool themeMode; // true for dark, false for light
  final String languageCode;

  Map<String, dynamic> toMap() {
    return {
      'defaultPlaybackSpeed': defaultPlaybackSpeed,
      'defaultSkipInterval': defaultSkipInterval,
      'syncEnabled': syncEnabled,
      'themeMode': themeMode,
      'languageCode': languageCode,
      'preferredDirectoryPath': preferredDirectoryPath,
      'localLibraryPath': localLibraryPath,
    };
  }

  static UserSettings defaultSettings() {
    return const UserSettings(
      defaultPlaybackSpeed: 1,
      defaultSkipInterval: 30,
      syncEnabled: true,
      themeMode: false,
      languageCode: 'en',
    );
  }

  UserSettings copyWith({
    double? defaultPlaybackSpeed,
    int? defaultSkipInterval,
    bool? syncEnabled,
    bool? themeMode,
    String? languageCode,
    String? preferredDirectoryPath,
    String? localLibraryPath,
  }) {
    return UserSettings(
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      defaultSkipInterval: defaultSkipInterval ?? this.defaultSkipInterval,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      preferredDirectoryPath: preferredDirectoryPath ?? this.preferredDirectoryPath,
      localLibraryPath: localLibraryPath ?? this.localLibraryPath,
    );
  }
}
